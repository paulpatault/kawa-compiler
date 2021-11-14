open Ast
open Pimp
open Utils.Exn_brk
open Utils.List_funcs

let mk_fun_name s1 s2 = s1 ^ "_" ^ s2
let mk_descr_name class_name = Printf.sprintf "descr_%s" class_name


let tr_prog (prog: Kawa.program): program =

  let classes_info_in_kawa = Hashtbl.create 42 in

  let classes_tbl_find_by_name name =
    let (attr, _), _parent = Hashtbl.find classes_info_in_kawa name in
    List.length attr + 1
  in

  let curr_class = ref "" in

  let rec class_of_expr = function
    | Kawa.Cst _ | Kawa.Bool _ | Kawa.Binop _ -> assert false
    | Kawa.(Get (Var x)) ->
        begin match List.assoc_opt x prog.globals with
        | Some (Kawa.(Typ_Class s)) -> s
        | _ -> assert false
        end
    | Kawa.This ->
        !curr_class
    | Kawa.New(class_name, _params) ->
        class_name
    | Kawa.(Get (Field(e, x))) ->
        let c_e = class_of_expr e.expr_desc in
        let (attr, _), _parent = Hashtbl.find classes_info_in_kawa c_e in
        begin match List.assoc_opt x attr with
        | Some (Kawa.(Typ_Class s)) -> s
        | _ -> assert false
        end
    | Kawa.MethCall(e, f, _) ->
        let c_e = class_of_expr e.expr_desc in
        let (_, meths), _parent = Hashtbl.find classes_info_in_kawa c_e in
        begin match List.assoc_opt f meths with
        | Some (Kawa.(Typ_Class s)) -> s
        | _ -> assert false
        end
  in

  let get_dec expr info =
    let unpair, name =
      match info with
      | `Method f -> snd, f
      | `Attribut x -> fst, x
    in
    try
      let pair, _parent = Hashtbl.find classes_info_in_kawa (class_of_expr expr) in
      let mlist = unpair pair |> List.rev in
      List.iteri (fun meth_or_attr_i (name', _typ) ->
        if name = name' then raise (Brk_i meth_or_attr_i)
      ) mlist;
      assert false
    with Brk_i dec -> 4 * (dec + 1)
  in

  (* **********************)
  (* Tradution d'un binop *)
  (* **********************)
  let tr_op = function
    | Kawa.Add -> Add
    | Kawa.Mul -> Mul
    | Kawa.Lt  -> Lt
    | Kawa.Le  -> Le
    | Kawa.Gt  -> Gt
    | Kawa.Ge  -> Ge
    | Kawa.Eq  -> Eq
    | Kawa.Neq -> Neq
    | Kawa.And -> And
    | Kawa.Or  -> Or
  in

  (* ****************************)
  (* Tradution d'une expression *)
  (* ****************************)
  let rec tr_expr = function
    | Kawa.Cst n ->
        Cst n

    | Kawa.Bool b ->
        Bool b

    | Kawa.Binop (op, e1, e2) ->
        Binop(tr_op op, tr_expr e1.expr_desc, tr_expr e2.expr_desc)

    | Kawa.(Get Var x)  ->
        Var x

    | Kawa.(Get Field(e, x)) ->
        let var = tr_expr e.expr_desc in
        let dec = get_dec e.expr_desc (`Attribut x) in
        Unop (Dec dec, var)

    | Kawa.This ->
        Var "this"

    | Kawa.New(class_name, params) ->
        let params = List.map (fun e -> tr_expr Kawa.(e.expr_desc)) params in
        (* 1. Allocation du bloc représentant l'objet *)
        let size = classes_tbl_find_by_name class_name in
        let alloc = Set("This_alloc_name", Unop (Alloc, Cst (4 * size))) in
        (* 2. Initialisation du premier champ du bloc, avec un pointeur vers
              le descripteur de classe *)
        let descr = mk_descr_name class_name in
        let addr = Addr descr in
        let set = Write(Var "This_alloc_name", addr) in
        (* 3. Appel du constructeur, avec comme paramètres l'objet qui vient d'être
              créé et les paramètres [a1] à [aN] *)
        let this = Var "This_alloc_name" in
        let expr2 =
          Call (
            FName (mk_fun_name class_name "constructor"),
            this::params
          ) in
        (* 4. suite et fin *)
        let seq = [alloc;set;Expr expr2] in
        Seq (seq, Var "This_alloc_name")

    | Kawa.MethCall(e, f, params) ->
        let e' = tr_expr e.expr_desc in
        let class_descr = Unop(Dec 0, e') in
        let dec = get_dec e.expr_desc (`Method f) in
        let f = Unop(Dec dec, class_descr) in
        let params = List.map (fun e -> tr_expr Kawa.(e.expr_desc)) params in
        Call(FPointer f, e'::params)
  in

  (* *****************************)
  (* Tradution d'une instruction *)
  (* *****************************)
  let rec tr_instr = function
    | Kawa.(Putchar (C c)) ->
        Putchar (PAscii (Char.code c))

    | Kawa.(Putchar (E e)) ->
        Putchar(PExpr (tr_expr e.expr_desc))

    | Kawa.If(e, b1, b2) ->
        If(tr_expr e.expr_desc, tr_seq b1, tr_seq b2)

    | Kawa.While(e, b) ->
        While(tr_expr e.expr_desc, tr_seq b)

    | Kawa.Return e ->
        Return(tr_expr e.expr_desc)

    | Kawa.Expr e ->
        Expr(tr_expr e.expr_desc)

    | Kawa.Set(Var x, e) ->
        Set(x, tr_expr e.expr_desc)

    | Kawa.Set(Field(e1, x), e2) ->
        let var = tr_expr e1.expr_desc in
        let e = tr_expr e2.expr_desc in
        let dec = get_dec e1.expr_desc (`Attribut x) in
        let addr = Binop(Add, var, Cst dec) in
        Write(addr, e)

  (* **************************)
  (* Tradution d'une sequence *)
  (* **************************)
  and tr_seq s = List.map (fun i -> tr_instr Kawa.(i.instr_desc)) s in

  (* *************************)
  (* Tradution d'une méthode *)
  (* *************************)
  let tr_method (c: Kawa.class_def) (meth: Kawa.method_def): function_def =
    (* concat class name *)
    let name = mk_fun_name c.class_name meth.method_name in
    let code = tr_seq meth.code in
    (* gestion du [this] *)
    (* ajouter un param: instance appellante*)
    let params = "this" :: List.map fst meth.params in
    let locals = "This_alloc_name" :: List.map fst meth.locals in
    {name;code;params;locals}
  in

  (* ************************)
  (* Tradution d'une classe *)
  (* ************************)

  let rec find_meth meth classe parent =
    try
      let classe = List.find (fun Kawa.{class_name;_} -> classe=class_name) prog.classes in
      List.find (fun Kawa.{method_name;_} -> meth=method_name) classe.methods
    with Not_found ->
      begin match parent with
      | Some p ->
          let _, parent = Hashtbl.find classes_info_in_kawa p in
          find_meth meth p parent
      | None -> assert false
      end
  in

  let tr_class (c: Kawa.class_def) =
    let attr =
      let (attr, _), _ = Hashtbl.find classes_info_in_kawa Kawa.(c.class_name) in
      List.fold_left (fun acc (name, _) ->
        name :: acc
      ) [] attr
    in

    let meth =
      let (_, meth), parent = Hashtbl.find classes_info_in_kawa Kawa.(c.class_name) in
        List.fold_left (fun acc (name, _typ) ->
          let mdef = find_meth name c.class_name parent in
          let code_trad = tr_method c mdef in
          (code_trad.name, code_trad) :: acc
        ) [] meth
    in

    Array.of_list attr, Array.of_list meth
  in


  (* ***********************)
  (* Tradution des classes *)
  (* ***********************)
  let tr_classes (classes: Kawa.class_def list) =

    List.iter (fun c ->
      match Kawa.(c.parent) with
      | Some parent ->
          let (parent_attr, parent_meths), _ = Hashtbl.find classes_info_in_kawa parent in

          let meths = List.fold_left
            (fun acc Kawa.{method_name;return;_} ->
              if List.mem_assoc method_name acc then
                replace_assoc acc method_name return
              else (method_name, return) :: acc)
            parent_meths Kawa.(c.methods)
          in

          let attr = List.fold_left
            (fun acc (attr_name, typ) ->
              if List.mem_assoc attr_name acc then
                replace_assoc acc attr_name typ
              else (attr_name, typ) :: acc)
            parent_attr Kawa.(c.attributes)
          in

          let pair = (attr, meths), Some parent in
          Hashtbl.add classes_info_in_kawa Kawa.(c.class_name) pair
      | None ->
          let meths = List.fold_left
            (fun acc Kawa.{method_name;return;_} -> (method_name, return) :: acc)
            [] Kawa.(c.methods)
          in
          let attr = List.fold_left
            (fun acc (attr_name, typ) -> (attr_name, typ) :: acc)
            [] Kawa.(c.attributes)
            |> List.rev
          in
          let pair = (attr, meths), None in
          Hashtbl.add classes_info_in_kawa Kawa.(c.class_name) pair
    ) classes;

    List.fold_left (fun acc c ->
      curr_class := Kawa.(c.class_name);
      let _attr, meth_arr = tr_class c in
      let acc' = Array.fold_right (fun (_, code) acc -> code :: acc) meth_arr [] in
      acc' @ acc
    ) [] classes |> List.rev

  in

  (* ***********************************)
  (* Fonction init:                    *)
  (* écriture statique des descripteur *)
  (* ***********************************)
  let mk_init () =
    let name = "Init_func" in
    let code = Hashtbl.fold (
      fun class_name ((_, meths), parent) acc ->
        let descr = mk_descr_name class_name in
        let constr, suite =
          match
            List.fold_left (fun acc (meth_name, _typ) ->
                (mk_fun_name class_name meth_name)::acc
            ) [] meths
          with
          | [] -> assert false
          | e::k -> e, k
        in
        let hd = match parent with
          | Some p -> Printf.sprintf "descr_%s" p
          | None -> "0"
        in
        StaticWrite(descr, hd::constr::suite) :: acc
    ) classes_info_in_kawa [] in
    {name;code;params=[];locals=[]}
  in

  (* ***************)
  (* Fonction main *)
  (* ***************)
  let mk_main main =
    let name = "main" in
    let code = tr_seq main in
    {name;code;params=[];locals=["This_alloc_name"]}
  in

  (* ***********************)
  (* "Main" de la fonction *)
  (* ***********************)
  let globals = List.map fst prog.globals in
  let fundef_list = tr_classes prog.classes in
  let main = mk_main prog.main in
  let functions = main::(mk_init ())::fundef_list in
  {functions;globals}
