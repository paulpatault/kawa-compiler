open Ast
open Pmimp

let get_unop = function
  | Pimp.Dec n -> Dec n
  | Pimp.Alloc -> Alloc
  | Pimp.Read  -> Read
  | Pimp.Not   -> Not

let rec isel_expr: Pimp.expression -> Pmimp.expression = function
  | Pimp.Cst n ->
      Cst n
  | Pimp.Bool b ->
      if b then Cst 1 else Cst 0
  | Pimp.Var x ->
      Var x
  | Pimp.(Unop(op, e)) ->
      Unop(get_unop op, isel_expr e)
  | Pimp.Addr s ->
      Addr s
  | Pimp.Seq(seq, e) ->
      Seq (List.map isel_instr seq, isel_expr e)
  | Pimp.Binop(op, e1, e2) ->
      let e1 = isel_expr e1 in
      let e2 = isel_expr e2 in
      begin match op with
      | Pimp.Add -> mk_add e1 e2
      | Pimp.Sub -> Binop(Sub, e1, e2)
      | Pimp.Mul -> mk_mul e1 e2
      | Pimp.Lt  -> mk_lt e1 e2
      | Pimp.Le  -> mk_le e1 e2
      | Pimp.Gt  -> mk_lt e2 e1
      | Pimp.Ge  -> mk_le e2 e1
      | Pimp.Eq  -> mk_eq e1 e2
      | Pimp.Neq -> mk_neq e1 e2
      | Pimp.And -> mk_and e1 e2
      | Pimp.Or  -> mk_or e1 e2
      | Pimp.Div -> Binop(Div, e1, e2)
      end
  | Pimp.Call(Pimp.FName x, el, tag) ->
      let l = List.map (isel_expr) el in
      Call(x, l, tag)
  | Pimp.Call(Pimp.FPointer e, el, tag) ->
      let l = List.map (isel_expr) el in
      CallPointeur(isel_expr e, l, tag)

and isel_instr: Pimp.instruction -> Pmimp.instruction = function
  | Pimp.Assert e ->
      Assert (isel_expr e)
  | Pimp.Putchar (PString s) ->
      Putchar (PString s)
  | Pimp.Putchar (PExpr e) ->
      Putchar (PExpr (isel_expr e))
  | Pimp.Set(s, e) ->
      Set(s, isel_expr e)
  | Pimp.If(c, b1, b2) ->
      If(isel_expr c, isel_seq b1, isel_seq b2)
  | Pimp.While(e, b) ->
      While(isel_expr e, isel_seq b)
  | Pimp.Return e ->
      Return(isel_expr e)
  | Pimp.Expr e ->
      Expr (isel_expr e)
  | Pimp.Write(e1, e2) ->
      Write(isel_expr e1, isel_expr e2)
  | Pimp.StaticWrite(s, el) ->
      StaticWrite(s, el)

and isel_seq (s: Pimp.sequence): Pmimp.sequence =
  List.map isel_instr s

let isel_fdef f = {
    name = Pimp.(f.name);
    code = isel_seq Pimp.(f.code);
    params = Pimp.(f.params);
    locals = Pimp.(f.locals);
  }

let isel_prog p = {
    functions = List.map isel_fdef Pimp.(p.functions);
    globals = Pimp.(p.globals);
  }
