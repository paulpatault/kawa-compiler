open Ast.Kawa
open Utils.Loc
open Utils.List_funcs

let typ_to_string = function
  | Typ_Int     -> "int"
  | Typ_Bool    -> "bool"
  | Typ_Void    -> "void"
  | Typ_Class f -> f

let op_to_string = function
  | Add -> "+"
  | Mul -> "*"
  | Lt  -> "<"
  | Eq  -> "=="

let typ_prog (prog: program): unit =

  let classes_info_in_kawa = Hashtbl.create 42 in

  let locals = ref [] in

  let curr_class = ref "" in

  let rec class_of_expr e =
    match e.expr_desc with
    | Get (Var x) ->
        begin try
          match List.assoc_opt x prog.globals with
            | Some (Typ_Class s) -> s
            | _ -> raise (Invalid_argument("todo |- local class"))
        with _ -> failwith (Printf.sprintf "not implemented |- Get (Var x) |- k2pimp class_of_expr || dans %s ||" !curr_class) end
    | This ->
        !curr_class
    | New(class_name, _params) ->
        class_name
    | Get (Field(e, x)) ->
        let c_e = class_of_expr e in
        let (attr, _), _parent = Hashtbl.find classes_info_in_kawa c_e in
        begin match List.assoc x attr with
        | Typ_Class s -> s
        | _ -> raise (Invalid_argument("_"))
        end
    | MethCall(e, f, _) ->
        let c_e = class_of_expr e in
        let (_, meths), _parent = Hashtbl.find classes_info_in_kawa c_e in
        begin match List.assoc f meths with
        | Typ_Class s, _params -> s
        | _ -> raise (Invalid_argument("_"))
        end
    | Cst _ | Bool _ | Binop _ -> assert false
  in

  let typ_op = function
    | Add -> Typ_Int
    | Mul -> Typ_Int
    | Lt  -> Typ_Bool
    | Eq  -> Typ_Bool
  in

  let rec typ_expr {expr_desc=e;expr_loc=loc} =
    match e with
    | Cst _ -> Typ_Int
    | Bool _ -> Typ_Bool
    | Binop (Eq, e1, e2) ->
        if typ_expr e1 = typ_expr e2 then Typ_Bool
        else error "" ~loc
    | Binop (op, e1, e2) ->
        let t1 = typ_expr e1 in
        let t2 = typ_expr e2 in
        let top = typ_op op in
        begin match t1, t2 with
        | Typ_Bool, Typ_Bool -> top
        | Typ_Int, Typ_Int -> top
        | _ -> error ~loc (Printf.sprintf "L'opérateur '%s' doit s'appliquer à deux variables de même type" (op_to_string op))
        end
    | Get mem_access ->
        typ_mem_access mem_access loc
    | This -> Typ_Class !curr_class
    | New(class_name, params) ->
        let (_, meths), _ = Hashtbl.find classes_info_in_kawa class_name in
        let _constr_typ, constr_params = List.assoc "constructor" meths in
        let params = List.map typ_expr params in
        typ_params params constr_params (Typ_Class class_name) loc

    | MethCall(e, f, params) ->
        let (_, meth), _ = Hashtbl.find classes_info_in_kawa (class_of_expr e) in
        begin match List.assoc_opt f meth with
        | Some (typ, meth_params) ->
            let params = List.map typ_expr params in
            typ_params params meth_params typ loc
        | None -> error (Printf.sprintf "La méthode %s n'existe pas" f) ~loc
        end

  and typ_params l1 l2 ret loc =
        let l = List.compare_lengths l1 l2 in
        begin match l with
        | 0 ->
            let i = ref 0 in
            List.iter2 (fun typ1 (_, typ2) ->
              incr i;
              if typ1 <> typ2 then
                error ~loc
                  (Printf.sprintf
                  "Le %d-ieme paramètre est du type <%s> alos qu'il devrait être du type <%s>"
                  !i (typ_to_string typ1) (typ_to_string typ2))
            ) l1 l2;
            ret
        | 1 ->
            error "Premier plus grand" ~loc
        | -1 ->
            error "Deuxième plus grand" ~loc
        | _ ->
            assert false
        end

  and typ_mem_access mem_access loc = match mem_access with
    | Var x ->
        begin match List.assoc_opt x !locals, List.assoc_opt x prog.globals with
          | Some t, _ -> t
          | _, Some t -> t
          | _ -> error ~loc (Printf.sprintf "la variable %s n'existe pas" x)
        end
    | Field(e, x) ->
        let (attr, _), _ = Hashtbl.find classes_info_in_kawa (class_of_expr e) in
        match List.assoc_opt x attr with
        | Some t -> t
        | None -> error ~loc (Printf.sprintf "l'attribut %s n'existe pas" x)
  in

  let rec typ_instr {instr_desc=i;instr_loc=loc} =
    match i with
    | Putchar _ ->
        Typ_Void
    | If(e, b1, b2) ->
        begin match typ_expr e, typ_seq b1, typ_seq b2 with
        | Typ_Bool, Typ_Void, Typ_Void -> Typ_Void
        | _, Typ_Void, Typ_Void -> error ~loc "e devrait etre bool"
        | _, _, Typ_Void -> error ~loc "b1 devrait etre void"
        | _, _, _ -> error ~loc "b2 devrait etre void"
        end
    | While(e, b) ->
        begin match typ_expr e, typ_seq b with
        | Typ_Bool, Typ_Void -> Typ_Void
        | _, Typ_Void -> error ~loc "e devrait etre bool"
        | _, _ -> error ~loc "b devrait etre void"
        end
    | Return _ ->
        Typ_Void
    | Expr e ->
        typ_expr e
    | Set(mem_access, e) ->
        begin match typ_mem_access mem_access loc, typ_expr e with
          | Typ_Int, Typ_Int
          | Typ_Bool, Typ_Bool ->
              Typ_Void
          | Typ_Class f, Typ_Class f' when f = f' ->
              Typ_Void
          | Typ_Int, _ ->
              error ~loc "e devrait etre int"
          | Typ_Bool, _ ->
              error ~loc "e devrait etre bool"
          | Typ_Class f, _ ->
              error ~loc (Printf.sprintf "e devrait etre %s" f)
          | _ -> error ~loc "todo"
        end

  and typ_seq s =
    match s with
    | [] -> Typ_Void
    | e::k ->
        match typ_instr e with
        | Typ_Void | Typ_Int | Typ_Bool | Typ_Class _ -> typ_seq k
  in

  let typ_method meth =
    locals := meth.params;
    List.iter (fun (var, typ) ->
      if List.mem_assoc var !locals then
        locals := replace_assoc !locals var typ
      else locals := (var, typ) :: !locals
    ) meth.locals;
    typ_seq meth.code
  in

  let rec find_meth meth classe parent =
    try
      let classe = List.find (fun {class_name;_} -> classe=class_name) prog.classes in
      List.find (fun {method_name;_} -> meth=method_name) classe.methods
    with Not_found ->
      begin match parent with
      | None -> assert false
      | Some p ->
          let _, parent = Hashtbl.find classes_info_in_kawa p in
          find_meth meth p parent
      end
  in

  let typ_class classe =
    let (_, meth), parent = Hashtbl.find classes_info_in_kawa classe.class_name in
    List.iter (fun (name, _typ) ->
      let mdef = find_meth name classe.class_name parent in
      match typ_method mdef with
      | Typ_Void -> ()
      | _ -> assert false
    ) meth
  in

  let typ_classes (classes: class_def list) =
    List.iter (fun c ->
      match c.parent with
      | Some parent ->
          let (parent_attr, parent_meths), _ = Hashtbl.find classes_info_in_kawa parent in

          let meths = List.fold_left
            (fun acc {method_name;return;params;_} ->
              if List.mem_assoc method_name acc then
                replace_assoc acc method_name (return, params)
              else (method_name, (return, params)) :: acc)
            parent_meths c.methods
          in

          let attr = List.fold_left
            (fun acc (attr_name, typ) ->
              if List.mem_assoc attr_name acc then
                replace_assoc acc attr_name typ
              else (attr_name, typ) :: acc)
            parent_attr c.attributes
          in

          let pair = (attr, meths), Some parent in
          Hashtbl.add classes_info_in_kawa c.class_name pair
      | None ->
          let meths = List.fold_left
            (fun acc {method_name;return;params;_} -> (method_name, (return, params)) :: acc)
            [] c.methods
          in
          let attr = List.fold_left
            (fun acc (attr_name, typ) -> (attr_name, typ) :: acc)
            [] c.attributes
            |> List.rev
          in
          let pair = (attr, meths), None in
          Hashtbl.add classes_info_in_kawa c.class_name pair
    ) classes;

    List.iter (fun c ->
      curr_class := c.class_name; typ_class c
    ) classes
  in

  typ_classes prog.classes;
  ignore(typ_seq prog.main)

