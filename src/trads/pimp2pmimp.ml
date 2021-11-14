(**
   Traduction de IMP vers MIMP.
   Deux objectifs
   - simplifier les expressions qui peuvent déjà être partiellement calculées,
   - sélectionner des opérateurs optimisés comme [Addi] lorsque c'est possible.
   La sélection repose sur des fonctions comme [mk_add] à définir dans le
   module MIMP.

   En dehors de ces simplifications et du codage des constantes booléennes par
   des entiers, la structure du programme reste la même.
 *)

open Ast
open Pmimp

let get_unop = function
  | Pimp.Dec n -> Dec n
  | Pimp.Alloc -> Alloc
  | Pimp.Read -> Read

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
  | Pimp.Binop(Pimp.Add, e1, e2) ->
      mk_add (isel_expr e1) (isel_expr e2)
  | Pimp.Binop(Pimp.Mul, e1, e2) ->
      mk_mul (isel_expr e1) (isel_expr e2)
  | Pimp.Binop(Pimp.Lt, e1, e2) ->
      mk_lt (isel_expr e1) (isel_expr e2)
  | Pimp.Binop(Pimp.Eq, e1, e2) ->
      mk_eq (isel_expr e1) (isel_expr e2)
  | Pimp.Call(Pimp.FName x, el) ->
      let l = List.map (isel_expr) el in
      Call(x, l)
  | Pimp.Call(Pimp.FPointer e, el) ->
      let l = List.map (isel_expr) el in
      CallPointeur(isel_expr e, l)

and isel_instr: Pimp.instruction -> Pmimp.instruction = function
  | Pimp.Putchar (PAscii n) ->
      Putascii n
  | Pimp.Putchar (PExpr e) ->
      Putchar(isel_expr e)
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
