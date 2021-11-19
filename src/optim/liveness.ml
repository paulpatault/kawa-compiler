open Ast.Vips

module S = Set.Make(String)


let def = function
  | Cst(r, _, _)
  | Addr(r, _, _)
  | Unop(r, _, _, _)
  | Call(r, _, _, _, _)
  | GetParam(r, _, _)
  | GetGlobal(r, _, _)
  | Binop(r, _, _, _, _) ->
      S.singleton r
  | Putchar(_, _)
  | Assert _
  | Write(_, _, _)
  | StaticWrite(_, _, _)
  | CJump(_, _, _)
  | Jump _
  | Return _
  | SetGlobal(_, _, _) ->
      S.empty

let use = function
  | Cst(_, _, _)
  | Addr(_, _, _)
  | Putchar(String _, _)
  | Jump _ ->
      S.empty
  | Assert (r, _)
  | Putchar(Reg r, _)
  | GetGlobal(r, _, _)
  | SetGlobal(_, r, _)
  | GetParam(r, _, _)
  | CJump(r, _, _)
  | Unop(_, _, r, _)
  | Return r ->
      S.singleton r
  | Binop(_, _, r1, r2, _)
  | Write(r1, r2, _) ->
      S.of_list [r1; r2]
  | StaticWrite(_, rlist, _)
  | Call(_, _, rlist, _, _) ->
      S.of_list rlist

let liveness fdef =
  let live_in = Hashtbl.create 32 in
  let live_out = Hashtbl.create 32 in

  let preds = Hashtbl.create 32 in

  Hashtbl.iter (fun l i ->
    match i with
      | Return _ -> ()
      | Cst(_, _, next)
      | Addr(_, _, next)
      | Unop (_, _, _, next)
      | Binop (_, _, _, _, next)
      | Jump(next)
      | GetGlobal(_, _, next)
      | SetGlobal(_, _, next)
      | GetParam(_, _, next)
      | Call(_, _, _, _, next)
      | Write(_, _, next)
      | StaticWrite(_, _, next)
      | Assert (_, next)
      | Putchar(_, next) ->
          begin match Hashtbl.find_opt preds next with
            | Some p -> Hashtbl.replace preds next (l::p)
            | None   -> Hashtbl.add preds next [l]
          end
      | CJump(_, next1, next2) ->
          begin match Hashtbl.find_opt preds next1 with
            | Some p -> Hashtbl.replace preds next1 (l::p)
            | None   -> Hashtbl.add preds next1 [l]
          end;
          begin match Hashtbl.find_opt preds next2 with
            | Some p -> Hashtbl.replace preds next2 (l::p)
            | None   -> Hashtbl.add preds next2 [l]
          end
    ) fdef.code;

  let a_traiter = Stack.create () in
  Hashtbl.iter (fun l _ ->
    Stack.push l a_traiter)
    fdef.code;

  while not (Stack.is_empty a_traiter) do
    let l = Stack.pop a_traiter in
    let i = Hashtbl.find fdef.code l in

    let new_out = match i with
      | Return _ -> S.empty
      | Cst(_, _, next)
      | Addr(_, _, next)
      | Unop (_, _, _, next)
      | Binop (_, _, _, _, next)
      | Jump(next)
      | GetGlobal(_, _, next)
      | SetGlobal(_, _, next)
      | GetParam(_, _, next)
      | Call(_, _, _, _, next)
      | Write(_, _, next)
      | StaticWrite(_, _, next)
      | Assert (_, next)
      | Putchar(_, next) ->
          begin match Hashtbl.find_opt live_in next with
            | Some e -> e
            | None   -> S.empty
          end
      | CJump(_, next1, next2) ->
          begin match Hashtbl.find_opt live_in next1, Hashtbl.find_opt live_in next2 with
            | Some e1, Some e2 -> S.union e1 e2
            | Some e1, None    -> e1
            | None,    Some e2 -> e2
            | None,    None    -> S.empty
          end
    in

    Hashtbl.replace live_out l new_out;

    let new_in =
      S.union (use i) (S.diff new_out (def i))
    in

    let diff = S.diff new_in
      begin match Hashtbl.find_opt live_in l with
        | Some e -> e
        | None -> S.empty
      end in

    if S.is_empty diff then ()
    else begin
      let preds =
        begin match Hashtbl.find_opt preds l with
          | Some e -> e
          | None -> []
        end in
      List.iter (fun e -> Stack.push e a_traiter) preds;
      Hashtbl.replace live_in l new_in;
    end

  done;

  live_in, live_out
