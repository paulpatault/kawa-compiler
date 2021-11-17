open Ast.Kawa
open Utils.List_funcs

let typ_to_string = function
  | Typ_Int     -> "int"
  | Typ_Bool    -> "bool"
  | Typ_Void    -> "void"
  | Typ_Class f -> f

let op_to_string = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"
  | Lt  -> "<"
  | Le  -> "<="
  | Gt  -> ">"
  | Ge  -> ">="
  | Eq  -> "=="
  | Neq -> "!="
  | And -> "&&"
  | Or  -> "||"

let typ_prog ?file (prog: program): unit =

  let error ?loc str = Utils.Loc.error ?file ?loc str in

  let classes_info_in_kawa = Hashtbl.create 42 in
  let locals = ref [] in
  let curr_class = ref "" in
  let curr_meth = ref "" in

  let rec class_of_expr e =
    match e.expr_desc with
    | Get (Var x) ->
        if Char.uppercase_ascii x.[0] = x.[0] then
          `Classe x
        else begin match List.assoc_opt x prog.globals, List.assoc_opt x !locals with
          | _, Some (Typ_Class s) -> `Instance s
          | Some (Typ_Class s), _ -> `Instance s
          | _ -> raise (Invalid_argument(""))
        end
    | This ->
        let (_, meths), _ = Hashtbl.find classes_info_in_kawa !curr_class in
        let _, _, tags = List.assoc !curr_meth meths in
        if List.mem "static" tags then
          error ~loc:e.expr_loc "Les méthodes statiques ne peuvent pas faire appel à <this>"
        else
          `Instance !curr_class
    | New(class_name, _params) ->
        `Instance class_name
    | Get (Field(e, x)) ->
        let c_e = match class_of_expr e with
          | `Instance i -> i
          | `Classe _ -> error "Les attributs statiques ne sont pas (encore?) implémentés" ~loc:e.expr_loc
        in
        let (attr, _), _parent = Hashtbl.find classes_info_in_kawa c_e in
        begin match List.assoc x attr with
        | Typ_Class s -> `Instance s
        | _ -> raise (Invalid_argument("_"))
        end
    | MethCall(e, f, _) ->
        let c_e = match class_of_expr e with
          | `Instance i -> i
          | _ -> error "TODO msg" ~loc:e.expr_loc
        in
        let (_, meths), _parent = Hashtbl.find classes_info_in_kawa c_e in
        begin match List.assoc f meths with
        | Typ_Class s, _params, _tags -> `Instance s
        | _ -> raise (Invalid_argument("_"))
        end
    | Cst _ | Bool _ | Binop _ -> assert false
  in

  let typ_op = function
    | Add | Sub
    | Mul | Div -> Typ_Int
    | Lt | Le
    | Gt | Ge
    | Eq | Neq
    | And | Or -> Typ_Bool
  in

  let rec typ_expr {expr_desc=e;expr_loc=loc} =
    match e with
    | Cst _ -> Typ_Int
    | Bool _ -> Typ_Bool
    | Binop ((Eq|Neq|And|Or), e1, e2) ->
        if typ_expr e1 = typ_expr e2 then Typ_Bool
        else error "" ~loc
    | Binop ((Add|Sub|Mul|Div|Lt|Le|Gt|Ge) as op, e1, e2) ->
        begin match typ_expr e1, typ_expr e2 with
        | Typ_Int, Typ_Int ->
            typ_op op
        | _ ->
            error ~loc (Printf.sprintf
              "L'opérateur '%s' doit s'appliquer à deux variables de type <int>"
              (op_to_string op))
        end
    | Get mem_access ->
        typ_mem_access mem_access loc
    | This ->
        let (_, meths), _ = Hashtbl.find classes_info_in_kawa !curr_class in
        let _, _, tags = List.assoc !curr_meth meths in
        if List.mem "static" tags then
          error ~loc "Les méthodes statiques ne peuvent pas faire appel à <this>"
        else
          Typ_Class !curr_class
    | New(class_name, params) ->
        begin try
          let (_, meths), _ = Hashtbl.find classes_info_in_kawa class_name in
          let _constr_typ, constr_params, _tags = List.assoc "constructor" meths in
          let params = List.map typ_expr params in
          typ_params params constr_params (Typ_Class class_name) loc
        with Not_found ->
          error ~loc (Printf.sprintf "La classe <%s> n'existe pas" class_name)
        end

    | MethCall(e, f, params) ->
        let ce = match class_of_expr e with
          | `Instance i -> i
          | `Classe m -> m
        in
        let ce, f =
          if f <> "super" then
            ce, f
          else
            begin match snd (Hashtbl.find classes_info_in_kawa ce) with
            | Some p ->
                p, !curr_meth
            | None ->
                error ~loc (Printf.sprintf
                  "Il n'est pas possible d'appeler la méthode <super> dans la classe <%s> car celle-ci n'a pas de classe mère" ce)
            end
        in

        let (_, meth), _ = Hashtbl.find classes_info_in_kawa ce in
        begin match List.assoc_opt f meth with
        | Some (typ, meth_params, _tags) ->
            let params = List.map typ_expr params in
            typ_params params meth_params typ loc
        | None -> error (Printf.sprintf "La classe <%s> n'a pas de méthode <%s>" ce f) ~loc
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
            error "La liste des paramètres effectifs est plus longue que la liste des paramètres formels" ~loc
        | -1 ->
            error "La liste des paramètres formels est plus longue que la liste des paramètres effectifs" ~loc
        | _ ->
            assert false
        end

  and typ_mem_access mem_access loc = match mem_access with
    | Var x ->
        begin match List.assoc_opt x !locals, List.assoc_opt x prog.globals with
          | Some t, _ -> t
          | _, Some t -> t
          | _ -> error ~loc (Printf.sprintf "La variable <%s> n'existe pas" x)
        end
    | Field(e, x) ->
        let ce = match class_of_expr e with
          | `Instance i -> i
          | `Classe _ -> error "Les attributs statiques ne sont pas (encore?) implémentés" ~loc
        in
        let (attr, _), _ = Hashtbl.find classes_info_in_kawa ce in
        begin match List.assoc_opt x attr with
        | Some t ->
            t
        | None ->
            error ~loc (Printf.sprintf "La classe <%s> ne possède pas d'attribut <%s>" ce x)
        end
  in

  let rec typ_instr {instr_desc=i;instr_loc=loc} info =
    match i with
    | Putchar (S _) ->
        Typ_Void
    | Putchar (E e) ->
        begin match typ_expr e with
        | Typ_Int | Typ_Bool -> Typ_Void
        | t ->
            error ~loc (Printf.sprintf
              "Le paramètre de putchar est de type <%s> alors qu'il devrait être de type <int> ou <bool>"
              (typ_to_string t))
        end
    | If(e, b1, b2) ->
        begin match typ_expr e, typ_seq b1 info, typ_seq b2 info with
        | Typ_Bool, Typ_Void, Typ_Void ->
            Typ_Void
        | t, Typ_Void, Typ_Void ->
            error ~loc (Printf.sprintf
              "La condition d'un <if> est de type <%s> alors qu'elle devrait être de type <bool>"
              (typ_to_string t))
        | _, t, Typ_Void ->
            error ~loc (Printf.sprintf
              "Ce bloc est de type <%s> alors qu'il devrait être de type <void>"
              (typ_to_string t))
        | _, _, t ->
            error ~loc (Printf.sprintf
              "Ce bloc est de type <%s> alors qu'il devrait être de type <void>"
              (typ_to_string t))
        end
    | While(e, b) ->
        begin match typ_expr e, typ_seq b info with
        | Typ_Bool, Typ_Void -> Typ_Void
        | t, Typ_Void ->
            error ~loc (Printf.sprintf
              "La condition d'un <while> est de type <%s> alors qu'elle devrait être de type <bool>"
              (typ_to_string t))
        | _, t ->
            error ~loc (Printf.sprintf
              "Ce bloc est de type <%s> alors qu'il devrait être de type <void>"
              (typ_to_string t))
        end
    | Return e ->
        let t = typ_expr e in
        let name, ret, _tag = info in
        if t = ret then
          Typ_Void
        else
          error ~loc (Printf.sprintf
            "La fonction <%s> est de type <%s> mais renvoie un type <%s>"
            name (typ_to_string ret) (typ_to_string t))
    | Expr e ->
        typ_expr e
    | Set(mem_access, e) ->
        begin match typ_mem_access mem_access loc, typ_expr e with
          | Typ_Int, Typ_Int
          | Typ_Bool, Typ_Bool ->
              Typ_Void
          | Typ_Class f, Typ_Class f' when f = f' ->
              Typ_Void
          | Typ_Int, t ->
              error ~loc (Printf.sprintf
                "L'expression donnée est de type <%s> alors qu'elle devrait etre <int>"
                (typ_to_string t))
          | Typ_Bool, t ->
              error ~loc (Printf.sprintf
                "L'expression donnée est de type <%s> alors qu'elle devrait etre <bool>"
                (typ_to_string t))
          | Typ_Class f, t ->
              error ~loc (Printf.sprintf
                "L'expression donnée est de type <%s> alors qu'elle devrait etre <class:%s>"
                (typ_to_string t) f)
          | Typ_Void, _ -> error ~loc "On ne peut rien assigner à un objet de type <void>"
        end

  and typ_seq s info =
    match s with
    | [] -> Typ_Void
    | e::k ->
        match typ_instr e info with
        | Typ_Void | Typ_Int | Typ_Bool | Typ_Class _ -> typ_seq k info
  in

  let typ_method c meth =
    curr_meth := meth.method_name;
    begin if meth.method_name = "constructor" && meth.return <> Typ_Void then
      error ~loc:meth.meth_loc (Printf.sprintf
        "Le constructeur de chaque classe doit être de type <void>, alors que celui de la classe <%s> est de type <%s>"
        c.class_name (typ_to_string meth.return))
    end;

    List.iter (fun (x, _typ) ->
      if Char.uppercase_ascii x.[0] = x.[0] then
      error ~loc:meth.meth_loc (Printf.sprintf
          "La variable <%s> commence par une majuscule, alors que les noms de variables doivent commencer par une minuscule"
          x);
    ) meth.locals;

    locals := meth.params;
    List.iter (fun (var, typ) ->
      if List.mem_assoc var !locals then
        locals := replace_assoc !locals var typ
      else locals := (var, typ) :: !locals
    ) meth.locals;

    typ_seq meth.code (meth.method_name, meth.return, meth.tag)
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
      match typ_method classe mdef with
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
            (fun acc {method_name;return;params;tag;_} ->
              if List.mem_assoc method_name acc then
                replace_assoc acc method_name (return, params, tag)
              else (method_name, (return, params, tag)) :: acc)
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
            (fun acc {method_name;return;params;tag;_} -> (method_name, (return, params, tag)) :: acc)
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

  List.iter (fun (x, _typ) ->
        if Char.uppercase_ascii x.[0] = x.[0] then
          error (Printf.sprintf
            "La variable <%s> commence par une majuscule, alors que les noms de variables doivent commencer par une minuscule"
            x
          );
  ) prog.globals;
  ignore(typ_seq prog.main ("main", Typ_Int, []));

