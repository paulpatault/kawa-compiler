open Ast
open Pimp
open Utils.Exn_brk
open Utils.List_funcs

let mk_fun_name s1 s2 = s1 ^ "_" ^ s2
let mk_descr_name class_name = Printf.sprintf "descr_%s" class_name

let mk_tags = function
  | [] -> []
  | l  ->
      List.map (function
        | "not_optim" -> Not_Optim
        | "static" -> Static
        | _ -> assert false
      ) l

let tr_prog (prog: Kawa.program) =

  let classes_info_in_kawa = Hashtbl.create 42 in

  let locals = ref [] in

  let classes_tbl_find_by_name name =
    let (attr, _), _parent = Hashtbl.find classes_info_in_kawa name in
    List.length attr + 1
  in

  let curr_class = ref "" in
  let curr_meth = ref "" in

  let rec class_of_expr = function
    | Kawa.Cst _ | Kawa.Bool _ | Kawa.Binop _ | Kawa.Unop _ | Kawa.Instanceof _ -> assert false
    | Kawa.(Get (Var x)) ->
        if Char.uppercase_ascii x.[0] = x.[0] then
          `Classe x
        else begin match List.assoc_opt x prog.globals, List.assoc_opt x !locals with
        | _, Some (Kawa.(Typ_Class s)) -> `Instance s
        | Some (Kawa.(Typ_Class s)), _ -> `Instance s
        | _ -> assert false
        end
    | Kawa.This ->
        `Instance !curr_class
    | Kawa.New(class_name, _params) ->
        `Instance class_name
    | Kawa.(Get (Field(e, x))) ->
        let c_e = match class_of_expr e.expr_desc with
          | `Instance i -> i
          | _ -> assert false
        in
        let (attr, _), _parent = Hashtbl.find classes_info_in_kawa c_e in
        begin match List.assoc_opt x attr with
        | Some (Kawa.(Typ_Class s)) -> `Instance s
        | _ -> assert false
        end
    | Kawa.MethCall(e, f, _) ->
        let c_e = match class_of_expr e.expr_desc with
          | `Instance i -> i
          | _ -> assert false
        in
        let (_, meths), _parent = Hashtbl.find classes_info_in_kawa c_e in
        begin match List.assoc_opt f meths with
        | Some (Kawa.(Typ_Class s), _tag) -> `Instance s
        | _ -> assert false
        end
  in

  let get_dec expr info =
    try
      let ce = match class_of_expr expr with
        | `Instance i -> i
        | _ -> assert false
      in
      let (attr, meths), _parent = Hashtbl.find classes_info_in_kawa ce in
      begin match info with
      | `Method name ->
          List.iteri (fun i (name', _) ->
            if name = name' then raise (Brk_i i)
            ) (List.rev meths)
      | `Attribut name ->
          List.iteri (fun i (name', _) ->
            if name = name' then raise (Brk_i i)
            ) (List.rev attr)
      end;
      assert false
    with Brk_i dec -> 4 * (dec + 1)
  in

  (* **********************)
  (* Tradution d'un binop *)
  (* **********************)
  let tr_op = function
    | Kawa.Add -> Add
    | Kawa.Sub -> Sub
    | Kawa.Mul -> Mul
    | Kawa.Div -> Div
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

    | Kawa.Unop (Not, e) ->
        Unop(Not, tr_expr e.expr_desc)

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

    | Kawa.Instanceof (_e, _s) -> (*TODO*) assert false


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
            this::params,
            [Not_Optim]
          ) in
        (* 4. suite et fin *)
        let seq = [alloc;set;Expr expr2] in
        Seq (seq, Var "This_alloc_name")

    | Kawa.MethCall(e, f, params) ->

        let params = List.map (fun e -> tr_expr Kawa.(e.expr_desc)) params in

        let classe_name, func, params = match class_of_expr e.expr_desc with
          | `Instance i ->
              let e' = tr_expr e.expr_desc in
              if f <> "super" then
                let class_descr = Unop(Dec 0, e') in
                let dec = get_dec e.expr_desc (`Method f) in
                let f' = Unop(Dec dec, class_descr) in
                i, FPointer f', e'::params
              else
                begin match snd (Hashtbl.find classes_info_in_kawa i) with
                | Some p ->
                    p, FName (mk_fun_name p !curr_meth), e'::params
                | None -> assert false
                end
          | `Classe c ->
              c, FName (mk_fun_name c f), params
        in

        let _typ, tag =
          let (_, meths), _ = Hashtbl.find classes_info_in_kawa classe_name in
          if f <> "super" then
            List.assoc f meths
          else begin
            List.assoc !curr_meth meths
          end
        in
        let tags = mk_tags tag in
        Call(func, params, tags)

  in

  (* *****************************)
  (* Tradution d'une instruction *)
  (* *****************************)
  let rec tr_instr = function
    | Kawa.Printf (s, params) ->
        let sl = String.split_on_char '%' s in
        let init = ref false in
        let lres = if s.[0] = '%' then (
            init := true;
            ref []
        ) else ref [Putchar (PString (List.hd sl))]
        in
        List.iteri (fun i s ->
          if !init then begin
            let s' = String.sub s 1 (String.length s - 1) in
            if s.[0] == 'd' then
              match List.nth params (i - 1) with
              | Kawa.E e ->
                  lres := Putchar (PString s') :: Putchar (PExpr (tr_expr e.expr_desc)) :: !lres;
              | _ -> assert false
            else if s.[0] == 's' then
              match List.nth params (i - 1) with
              | Kawa.S ss ->
                  lres := Putchar (PString (ss ^ s')) :: !lres;
              | _ -> assert false
            else
              assert false
          end else (init := true; lres := [Putchar (PString s)])
        ) sl;
        List.rev !lres
    | Kawa.(Putchar l) ->
        List.map (function
            Kawa.S s ->
              Putchar (PString s)
          | Kawa.E e ->
              Putchar(PExpr (tr_expr e.expr_desc))
        ) l
    | Kawa.If(e, b1, b2) ->
        [If(tr_expr e.expr_desc, tr_seq b1, tr_seq b2)]

    | Kawa.While(e, b) ->
        [While(tr_expr e.expr_desc, tr_seq b)]

    | Kawa.Return e ->
        [Return(tr_expr e.expr_desc)]

    | Kawa.Expr e ->
        [Expr(tr_expr e.expr_desc)]

    | Kawa.Set(Var x, e) ->
        [Set(x, tr_expr e.expr_desc)]

    | Kawa.Set(Field(e1, x), e2) ->
        let var = tr_expr e1.expr_desc in
        let e = tr_expr e2.expr_desc in
        let dec = get_dec e1.expr_desc (`Attribut x) in
        let addr = Binop(Add, var, Cst dec) in
        [Write(addr, e)]

  (* **************************)
  (* Tradution d'une sequence *)
  (* **************************)
  and tr_seq s =
    let l = List.map (fun i -> tr_instr Kawa.(i.instr_desc)) s in
    List.flatten l
  in

  (* *************************)
  (* Tradution d'une méthode *)
  (* *************************)
  let tr_method (c: Kawa.class_def) (meth: Kawa.method_def) =
    curr_meth := meth.method_name;
    locals := meth.locals @ meth.params;
    (* concat class name *)
    let name = mk_fun_name c.class_name meth.method_name in
    let code = tr_seq meth.code in
    (* gestion du [this] *)
    (* ajouter un param: instance appellante*)

    let params = List.map fst meth.params in
    let params =
      if List.mem "static" meth.tag then params
      else "this" :: params
    in
    let locals = "This_alloc_name" :: List.map fst meth.locals in
    let tag = mk_tags meth.tag in
    {name;code;params;locals;tag}
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

  let tr_class c =
    let (_, meth), parent = Hashtbl.find classes_info_in_kawa Kawa.(c.class_name) in
    List.fold_left (fun acc (name, _typ) ->
      let mdef = find_meth name c.class_name parent in
      let code_trad = tr_method c mdef in
      (code_trad.name, code_trad) :: acc
    ) [] meth
  in


  (* ***********************)
  (* Tradution des classes *)
  (* ***********************)
  let tr_classes classes =

    List.iter (fun c ->
      match Kawa.(c.parent) with
      | Some parent ->
          let (parent_attr, parent_meths), _ = Hashtbl.find classes_info_in_kawa parent in

          let meths = List.fold_left
            (fun acc Kawa.{method_name;return;tag;_} ->
              if List.mem_assoc method_name acc then
                replace_assoc acc method_name (return, tag)
              else (method_name, (return, tag)) :: acc)
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
            (fun acc Kawa.{method_name;return;tag;_} -> (method_name, (return, tag)) :: acc)
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

    List.fold_right (fun c acc ->
      curr_class := Kawa.(c.class_name);
      let meths = tr_class c in
      let acc' = List.fold_right (fun (_, code) acc -> code :: acc) meths [] in
      acc' @ acc
    ) classes []

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
    {name;code;params=[];locals=[];tag=[]}
  in

  (* ***************)
  (* Fonction main *)
  (* ***************)
  let mk_main main =
    let name = "main" in
    let code = tr_seq main in
    {name;code;params=[];locals=["This_alloc_name"];tag=[]}
  in

  (* ***********************)
  (* "Main" de la fonction *)
  (* ***********************)
  let globals = List.map fst prog.globals in
  let fundef_list = tr_classes prog.classes in
  let main = mk_main prog.main in
  let functions = main::(mk_init ())::fundef_list in
  {functions;globals}
