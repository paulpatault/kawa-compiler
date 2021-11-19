open Ast.Kawa

let annot_prog (prog: program): program =

  let rec is_pure_expr {expr_desc=e;_} =
    match e with
    | Cst _ | Bool _ | Get _ | This | Instanceof _ -> true
    | Unop (_, e) ->
        is_pure_expr e
    | Binop (_, e1, e2) ->
        is_pure_expr e1 && is_pure_expr e2
    | New(_, params) ->
        List.for_all is_pure_expr params
    | MethCall(_e, _f, _params) ->
        (* todo : rendre is_pure_meth *)
        false
  in

  let rec pure_instr {instr_desc=i;_} =
    match i with
    | Printf _
    | Putchar _
    | Assert _
    | Set _ -> false
    | If(e, b1, b2) ->
        is_pure_expr e && is_pure_seq b1 && is_pure_seq b2
    | While(e, b) ->
        is_pure_expr e && is_pure_seq b
    | Return e -> is_pure_expr e
    | Expr e -> is_pure_expr e

  and is_pure_seq s =
    List.for_all pure_instr s
  in

  let annot_method meth =
    if List.mem "not_optim" meth.tag then
      meth
    else if is_pure_seq meth.code then
      meth
    else
      mk_meth_def ~tag:("not_optim"::meth.tag) meth
  in

  let annot_class classe =
    let methods = List.map (fun m -> annot_method m) classe.methods in
    mk_class_def ~methods classe
  in

  let annot_classes (classes: class_def list) =
    List.map (fun c ->
      annot_class c
    ) classes
  in

  mk_prog ~classes:(annot_classes prog.classes) prog
