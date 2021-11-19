open Ast.Pimp
open Printf

let pp_binop: binop -> string = function
  | Add -> "+"
  | Mul -> "*"
  | Sub -> "-"
  | Div -> "/"
  | Lt  -> "<"
  | Le  -> "<="
  | Gt  -> ">"
  | Ge  -> ">="
  | Eq  -> "=="
  | Neq  -> "!="
  | And  -> "&&"
  | Or  -> "||"


let pp_program prog out_channel =
  let print s = fprintf out_channel s in
  let margin = ref 0 in
  let print_margin () = for _ = 1 to 2 * !margin do print " " done in

  let rec pp_instruction = function
    | Putchar (PString s) ->
        print "putchar(\"%s\");" s
    | Putchar (PExpr e) ->
        print "putchar(%s);" (pp_expression e)
    | Set(x, e) ->
        print "%s = %s;" x (pp_expression e)
    | If(c, s1, s2) ->
        print "if (%s) {\n" (pp_expression c);
        incr margin; pp_seq s1; decr margin;
        print_margin(); print "} else {\n";
        incr margin; pp_seq s2; decr margin;
        print_margin(); print "}"
    | While(c, s) ->
        print "while (%s) {\n" (pp_expression c);
        incr margin; pp_seq s; decr margin;
        print_margin(); print "}"
    | Return(e) ->
        print "return(%s);" (pp_expression e)
    | Expr(e) ->
        print "%s;" (pp_expression e)
    | Write(e1, e2) ->
        print "write(%s, %s);" (pp_expression e1) (pp_expression e2)
    | StaticWrite(s, sl) ->
        let sl = List.fold_left (fun acc si -> acc ^ ", " ^ si) "" sl in
        print "staticwrite(%s%s);" s sl


  and pp_seq = function
    | [] -> ()
    | i::seq -> print_margin(); pp_instruction i; print "\n"; pp_seq seq

  and pp_expression: expression -> string = function
  | Cst(n) ->
      string_of_int n
  | Bool(b) ->
      if b then "true" else "false"
  | Var(x) -> x
  | Unop(Dec n, e) ->
      sprintf "%d(%s)" n (pp_expression e)
  | Unop(Read, e) ->
      sprintf "read(%s)" (pp_expression e)
  | Unop(Not, e) ->
      sprintf "not(%s)" (pp_expression e)
  | Unop(Alloc, e) ->
      sprintf "alloc(%s)" (pp_expression e)
  | Binop(op, e1, e2) ->
      sprintf "(%s %s %s)" (pp_expression e1) (pp_binop op) (pp_expression e2)
  | Call(FName f, args, tag) ->
      sprintf "%s(%s) @<tag:%s>" f (pp_args args) (pp_tag tag)
  | Seq(seq, e) ->
      List.iter (fun i -> pp_instruction i; print "\n"; print_margin ()) seq;
      pp_expression e
  | Addr s ->
      sprintf "addr(%s)" s
  | Call(FPointer f, args, tag) ->
      sprintf "fpointeur:%s(%s) @<tags:%s>" (pp_expression f) (pp_args args) (pp_tag tag)

  and pp_tag = function
    | [] -> ""
    | [Not_Optim] -> "Not_Optim"
    | [Static]    -> "Static"
    | a::args -> sprintf "%s, %s" (pp_tag [a]) (pp_tag args)

  and pp_args: expression list -> string = function
    | [] -> ""
    | [a] -> pp_expression a
    | a::args -> sprintf "%s, %s" (pp_expression a) (pp_args args)
  in

  let rec pp_params = function
    | [] -> ""
    | [x] -> x
    | x::params -> sprintf "%s, %s" x (pp_params params)
  in

  let pp_var x = print_margin(); print "var %s;\n" x in

  let rec pp_vars = function
    | [] -> ()
    | [x] -> pp_var x; print "\n"
    | x::vars -> pp_var x; pp_vars vars
  in

  let pp_function fdef =
    print "function %s(%s) @<tag:%s> {\n" fdef.name (pp_params fdef.params) (pp_tag fdef.tag);
    incr margin;
    pp_vars fdef.locals;
    pp_seq fdef.code;
    decr margin;
    print "}\n\n"
  in

  pp_vars prog.globals;
  List.iter pp_function prog.functions;
