open Ast
open Vips

let translate_fdef f =

  let code = Hashtbl.create 32 in

  let new_label =
    let f = Pmimp.(f.name) in
    let count = ref 0 in
    fun () -> incr count; Printf.sprintf "%s_%i" f !count
  in

  let add_instr i =
    let l = new_label () in
    Hashtbl.add code l i;
    l
  in

  let locals = Hashtbl.create 8 in
  List.iter (fun x -> Hashtbl.add locals x (new_reg())) Pmimp.(f.locals);
  let params = Hashtbl.create 8 in
  List.iteri (fun i e -> Hashtbl.add params e i) Pmimp.(f.params);

  let rec translate_expr r e next = match e with
    | Pmimp.Cst n ->
       let i = Cst(r, n, next) in
       add_instr i

    | Pmimp.Var x ->
        begin match Hashtbl.find_opt locals x, Hashtbl.find_opt params x with
          | Some e, None -> add_instr (Unop(r, Move, e, next))
          | None, Some e -> add_instr (GetParam(r, e, next))
          | _            -> add_instr (GetGlobal(r, x, next))
        end

    | Pmimp.Addr s ->
       let i = Addr(r, s, next) in
       add_instr i

    | Pmimp.Unop(op, e') ->
        let op' = match op with
         | Pmimp.Addi n   -> Addi n
         | Pmimp.Subi n   -> Subi n
         | Pmimp.ShiftL n -> ShiftL n
         | Pmimp.Alloc    -> Alloc
         | Pmimp.Read     -> Read
         | Pmimp.Not      -> Not
         | Pmimp.Dec n    -> Dec n
        in

        let tmp = new_reg() in
        let i = Unop(r, op', tmp, next) in
        let l = add_instr i in
        translate_expr tmp e' l

    | Pmimp.Binop(op, e1, e2) ->
        let op' =
          match op with
          | Pmimp.Lt  -> Lt
          | Pmimp.Le  -> Le
          | Pmimp.Mul -> Mul
          | Pmimp.Div -> Div
          | Pmimp.Add -> Add
          | Pmimp.Sub -> Sub
          | Pmimp.Eq  -> Eq
          | Pmimp.Neq -> Neq
          | Pmimp.And -> And
          | Pmimp.Or  -> Or
        in
        let tmp1 = new_reg () in
        let tmp2 = new_reg () in
        let l = add_instr (Binop(r, op', tmp1, tmp2, next)) in
        let l1 = translate_expr tmp1 e1 l in
        translate_expr tmp2 e2 l1

    | Pmimp.Call(f, args, tag) ->
        let tmps = List.map (fun _ -> new_reg ()) args in
        let l = add_instr (Call(r, FName f, tmps, tag, next)) in
        translate_args tmps args l

    | Pmimp.CallPointeur(fp, args, tag) ->
        let tmps = List.map (fun _ -> new_reg ()) args in
        let f = new_reg () in
        let l = add_instr (Call(r, FPointeur f, tmps, tag, next)) in
        let l = translate_expr f fp l in
        translate_args tmps args l

    | Pmimp.Seq(seq, e) ->
        let next = translate_expr r e next in
        let first_next = ref next in
        List.iter (fun e ->
          first_next := translate_instr e !first_next;
        ) (List.rev seq);
        !first_next


  and translate_args tmps args next = match tmps, args with
    | [], [] -> next
    | t::tmps, a::args ->
        translate_args tmps args next |> translate_expr t a
    | _,_ -> assert false

  and translate_instr i next = match i with

    | Pmimp.If(e, s1, s2) ->
        let r = new_reg () in
        let lthen = translate_seq s1 next in
        let lelse = translate_seq s2 next in
        let ltest = add_instr (CJump(r, lthen, lelse)) in
        translate_expr r e ltest

    | Pmimp.While(e, s) ->
        let r = new_reg () in
        let ljump = new_label() in
        let le = translate_expr r e ljump in
        let lloop = translate_seq s le in
        Hashtbl.add code ljump (CJump(r, lloop, next));
        le

    | Pmimp.Putchar (Pmimp.PString s) ->
        let lput = new_label() in
        Hashtbl.add code lput (Putchar (String s, next));
        lput

    | Pmimp.Putchar (Pmimp.PExpr e) ->
        let r = new_reg () in
        let lput = new_label() in
        let l = translate_expr r e lput in
        Hashtbl.add code lput (Putchar(Reg r, next));
        l

    | Pmimp.Return e ->
        let r = new_reg () in
        let l = add_instr (Return r) in
        translate_expr r e l

    | Pmimp.Expr e ->
        let r = new_reg () in
        translate_expr r e next

    | Pmimp.Set(s, e) ->
        let r = new_reg () in
        let lset = new_label () in

        let le = translate_expr r e lset in

        let c = begin match Hashtbl.find_opt locals s with
          | Some local -> Unop(local, Move, r, next)
          | None       -> SetGlobal(s, r, next)
        end in

        Hashtbl.add code lset c;
        le

    | Pmimp.Write(e1, e2) ->
        let tmp1 = new_reg () in
        let tmp2 = new_reg () in
        let l = add_instr (Write(tmp1, tmp2, next)) in
        let l1 = translate_expr tmp1 e1 l in
        translate_expr tmp2 e2 l1

    | Pmimp.StaticWrite(s, el) ->
        add_instr (StaticWrite(s, el, next))

  and translate_seq s next =
     let first_next = ref next in
     List.iter (fun e ->
       first_next := translate_instr e !first_next;
       ) (List.rev s);
    !first_next
  in
  let tmp = new_reg() in
  let l = add_instr (Return tmp) in
  let l = add_instr (Cst(tmp, 0, l)) in
  let entry = translate_seq Pmimp.(f.code) l in

  {
    name = Pmimp.(f.name);
    code;
    entry;
  }

let translate_prog p = {
    globals = Pmimp.(p.globals);
    functions = List.map translate_fdef Pmimp.(p.functions)
  }
