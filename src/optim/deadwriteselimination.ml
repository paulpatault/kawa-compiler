open Ast.Vips
open Liveness

let dwe_step fdef =
  let _, live_out = liveness fdef in
  let change = ref false in
  Hashtbl.iter (fun l i ->
      match i with
      | Cst(r, _, next)
      | Unop(r, (Addi _ | Subi _ | ShiftL _ | Move), _, next)
      | Binop(r, _, _, _, next)
      | GetGlobal(r, _, next)
      | GetParam(r, _, next) ->
      (* | Call(r, _, _, next) -> *)
         if S.mem r (Hashtbl.find live_out l) then
           ()
         else begin
             Hashtbl.replace fdef.code l (Jump next);
             change := true
           end
      | _ -> ()
    ) fdef.code;
  !change

let dwe fdef =
  while dwe_step fdef do () done

let dwe_prog prog =
  List.iter dwe prog.functions
