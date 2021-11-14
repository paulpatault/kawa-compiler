open Ast.Gips
open Printf

let pp_unop: unop -> string = function
  | Addi n -> sprintf "%i+ " n
  | Subi n -> sprintf "(-%i)+ " n
  | Alloc  -> "alloc "
  | Read   -> "read "
  | Move   -> ""
  | _ -> assert false

let pp_binop: binop -> string = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Lt  -> "<"
  | Le  -> "<="
  | Eq  -> "=="

let rec pp_args: string list -> string = function
  | [] -> ""
  | [a] -> a
  | a::args -> sprintf "%s,%s" a (pp_args args)

let pp_program prog out_channel =
  let print s = fprintf out_channel s in

  let pp_instruction = function
    | Cst(d, n, l) ->
        print "%s <- %i        | %s" d n l
    | Addr(d, s, l) ->
        print "%s <- addr(%s)  | %s" d s l
    | Unop(d, Dec n, r, l) ->
       print "%s <- %i(%s)      | %s" d n r l
    | Unop(d, ShiftL n, r, l) ->
        print "%s <- %s%s      | %s" d r (sprintf "<<%i" n) l
    | Unop(d, op, r, l) ->
        print "%s <- %s%s      | %s" d (pp_unop op) r l
    | Binop(d, op, r1, r2, l) ->
        print "%s <- %s %s %s  | %s" d r1 (pp_binop op) r2 l
    | GetLocal(d, k, l) ->
        print "%s <- local[%i] | %s" d k l
    | SetLocal(k, r, l) ->
        print "local[%i] <- %s | %s" k r l
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
    | Call(FName f, l) ->
        print "call %s         | %s" f l
    | Call(FPointeur fp, l) ->
        print "call %s         | %s" fp l
    | Syscall l ->
        print "syscall         | %s" l
    | Push(r, l) ->
        print "push(%s)        | %s" r l
    | Pop(r, l) ->
        print "%s <- pop()     | %s" r l
    | Write(r1, r2, l) ->
        print "write(%s, %s)   | %s" r1 r2 l
    | StaticWrite(s, sl, l) ->
        let sl = List.fold_left (fun acc si -> acc ^ "," ^ si) "" sl in
        print "staticwrite(%s%s)     | %s " s sl l
    | Return ->
        print "return"
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
