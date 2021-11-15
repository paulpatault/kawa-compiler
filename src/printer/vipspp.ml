open Ast.Vips
open Printf

let pp_unop: unop -> string = function
  | Addi n   -> sprintf "%i+ " n
  | Subi n   -> sprintf "(-%i)+ " n
  | Move     -> "(move) "
  | Alloc  -> "alloc "
  | Read   -> "read "
  | _        -> assert false

let pp_binop: binop -> string = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Lt  -> "<"
  | Le  -> "<="
  | Eq  -> "=="
  | Neq -> "!="
  | And  -> "&&"
  | Or  -> "||"

let rec pp_args: string list -> string = function
  | [] -> ""
  | [a] -> a
  | a::args -> sprintf "%s,%s" a (pp_args args)

let pp_program prog out_channel =
  let print s = fprintf out_channel s in

  let rec pp_instruction = function
    | Cst(d, n, l) ->
       print "%s <- %i        | %s" d n l
    | Addr(d, s, l) ->
       print "%s <- addr(%s)  | %s" d s l
    | Unop(d, ShiftL n, r, l) ->
       print "%s <- %s%s      | %s" d r (sprintf "<<%i" n) l
    | Unop(d, Dec n, r, l) ->
       print "%s <- %i(%s)      | %s" d n r l
    | Unop(d, op, r, l) ->
       print "%s <- %s%s      | %s" d (pp_unop op) r l
    | Binop(d, op, r1, r2, l) ->
       print "%s <- %s %s %s  | %s" d r1 (pp_binop op) r2 l
    | GetGlobal(d, x, l) ->
       print "%s <- *%s       | %s" d x l
    | SetGlobal(x, r, l) ->
       print "*%s <- %s       | %s" x r l
    | GetParam(d, k, l) ->
       print "%s <- param[%i] | %s" d k l
    | Jump l ->
       print "jump            | %s" l
    | CJump(r, l1, l2) ->
       print "jump %s when %s | %s" l1 r l2
    | Putchar(Reg r, l) ->
       print "putchar(%s)     | %s" r l
    | Putchar(Ascii n, l) ->
        print "putascii(%d);     | %s" n l
    | Call(d, FName f, rs, tag, l) ->
       print "%s <- %s(%s) @<tag:%s>   | %s" d f (pp_args rs) (pp_tag tag) l
    | Call(d, FPointeur f, rs, tag, l) ->
       print "%s <- _fpointeur_%s(%s) @<tag:%s>   | %s" d f (pp_args rs) (pp_tag tag) l
    | Return r ->
       print "return %s"            r
    | Write(r1, r2, l) ->
       print "write(%s, %s)     | %s" r1 r2 l
    | StaticWrite(s, sl, l) ->
        let sl = List.fold_left (fun acc si -> acc ^ "," ^ si) "" sl in
        print "staticwrite(%s%s)     | %s" s sl l

  and pp_tag = function
    | [] -> ""
    | [Ast.Pimp.Not_Optim] -> "Not_Optim"
    | [Ast.Pimp.Static]    -> "Static"
    | a::args -> sprintf "%s, %s" (pp_tag [a]) (pp_tag args)
  in

  let pp_var x = print "var %s;\n" x in
  let rec pp_vars = function
    | [] -> ()
    | [x] -> pp_var x; print "\n"
    | x::vars -> pp_var x; pp_vars vars
  in

  let pp_function fdef =
    print "function %s {\n" fdef.name;
    print "  entry: %s\n\n" fdef.entry;
    Hashtbl.iter (fun l i ->
        print "  %s:  " l;
        pp_instruction i;
        print "\n"
      ) fdef.code;
    print "}\n\n"
  in

  pp_vars prog.globals;
  List.iter pp_function prog.functions;
