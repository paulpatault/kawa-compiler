open Ast
open Gips

let opt_moves fdef =

  let tr_instr i = match i with
      | Unop(r, Move, r1, next) when r = r1 -> Jump next
      | _ -> i
  in

  let code = Hashtbl.create 32 in

  Hashtbl.iter (fun reg i -> Hashtbl.add code reg (tr_instr i)) fdef.code;

  {name=fdef.name; code; entry=fdef.entry}

let translate_prog prog =
  let function_codes = List.map opt_moves prog.functions in
  { globals=prog.globals; functions=function_codes }
