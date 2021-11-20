open Ast
open Gips
open Optim.Register_allocation

let tr_unop = function
  | Vips.Addi n   -> Addi n
  | Vips.Subi n   -> Subi n
  | Vips.Move     -> Move
  | Vips.Not      -> Not
  | Vips.Read     -> Read
  | Vips.Alloc    -> Alloc
  | Vips.ShiftL n -> ShiftL n
  | Vips.Dec n    -> Dec n

let tr_binop = function
  | Vips.Add -> Add
  | Vips.Div -> Div
  | Vips.Sub -> Sub
  | Vips.Mul -> Mul
  | Vips.Lt  -> Lt
  | Vips.Le  -> Le
  | Vips.Eq  -> Eq
  | Vips.Neq -> Neq
  | Vips.And -> And
  | Vips.Or -> Or

let translate_fdef fdef =
  let code = Hashtbl.create 32 in

  let new_label =
    let f = Vips.(fdef.name) in
    let count = ref 0 in
    fun () -> incr count; Printf.sprintf "%s_g_%i" f !count
  in
  let add_instr i =
    let l = new_label () in
    Hashtbl.add code l i;
    l
  in

  let reg_use_list = ref [] in

  let save_reg l =
    let empile = fun acc e -> add_instr(Push(e, acc)) in
    List.fold_left empile l (!reg_use_list)
  in
  let rest_reg l =
    let depile = fun acc e -> add_instr(Pop(e, acc)) in
    List.fold_left depile l (List.rev !reg_use_list)
  in

  let reg_use_add_params () =
    reg_use_list := [Mips.a0;Mips.a1; Mips.a2; Mips.a3] @ !reg_use_list
  in

  let reg_use r =
    let arr =
      match r.[1] with
        | 't' -> [|Mips.t0;Mips.t1;Mips.t2;Mips.t3;Mips.t4; Mips.t5;Mips.t6;Mips.t7;Mips.t8;Mips.t9|]
        | 's' -> [|Mips.s0;Mips.s1;Mips.s2;Mips.s3;Mips.s4;Mips.s5;Mips.s6;Mips.s7|]
        | _ -> assert false
    in
    let reg = arr.(int_of_char r.[2] - 48) in
    if List.mem reg !reg_use_list then ()
    else reg_use_list := reg::!reg_use_list
  in

  let alloc, nb_locals = allocate_function fdef in

  let tmp1 = "$t0" in
  let tmp2 = "$t1" in
  let arg  = "$a0" in
  let scod = "$v0" in
  let ret  = "$v0" in
  let sp   = "$sp" in
  let fp   = "$fp" in
  let ra   = "$ra" in

  let tr_instr i = match i with
    | Vips.Assert (r, line, next) ->
       begin match Hashtbl.find alloc r with
       | Register r' ->
           reg_use r';
           Assert(r', line, next)
       | Stacked k ->
          let l = add_instr (SetLocal(k, tmp1, next)) in
          Assert(tmp1, line, l)
       end

    | Vips.Cst(r, n, next) ->
       begin match Hashtbl.find alloc r with
       | Register r' ->
           reg_use r';
           Cst(r', n, next)
       | Stacked k ->
          let l = add_instr (SetLocal(k, tmp1, next)) in
          Cst(tmp1, n, l)
       end

    | Vips.Addr(r, s, next) ->
       begin match Hashtbl.find alloc r with
       | Register r' ->
           reg_use r';
           Addr(r', s, next)
       | Stacked k ->
          let l = add_instr (SetLocal(k, tmp1, next)) in
          Addr(tmp1, s, l)
       end


    | Vips.Unop(r1, op, r2, next) ->
       begin match Hashtbl.find alloc r1, Hashtbl.find alloc r2 with
         | Register r1', Register r2' ->
             reg_use r1';
             reg_use r2';
             Unop(r1', tr_unop op, r2', next)
         | Register r1', Stacked k2 ->
             reg_use r1';
             let l = add_instr (Unop(r1', tr_unop op, tmp1, next)) in
             GetLocal(tmp1, k2, l)
         | Stacked k1, Register r2' ->
             reg_use r2';
             let l = add_instr (Unop(r2', tr_unop op, tmp1, next)) in
             GetLocal(tmp1, k1, l)
         | Stacked k1, Stacked k2 ->
             let l = add_instr (SetLocal(k2, tmp1, next)) in
             let l = add_instr (Unop(tmp1, tr_unop op, tmp1, l)) in
             GetLocal(tmp1, k1, l)
       end

    | Vips.Binop(r, op, r1, r2, next) ->
       begin match Hashtbl.find alloc r, Hashtbl.find alloc r1, Hashtbl.find alloc r2 with
         | Register r', Register r1', Register r2' ->
             reg_use r'; reg_use r1'; reg_use r2';
             Binop(r', tr_binop op, r1', r2', next)

         | Register r', Register r1', Stacked k2 ->
             reg_use r'; reg_use r1';
             let l = add_instr (Binop(r', tr_binop op, r1', tmp1, next)) in
             GetLocal(tmp1, k2, l)

         | Register r', Stacked k1, Register r2' ->
             reg_use r'; reg_use r2';
             let l = add_instr (Binop(r', tr_binop op, tmp1, r2', next)) in
             GetLocal(tmp1, k1, l)

         | Register r', Stacked k1, Stacked k2 ->
             reg_use r';
             let l = add_instr (Binop(r', tr_binop op, tmp1, tmp2, next)) in
             let l = add_instr (GetLocal(tmp1, k1, l)) in
             GetLocal(tmp2, k2, l)

         | Stacked k, Register r1', Register r2' ->
             reg_use r1'; reg_use r2';
             let l = add_instr (SetLocal(k, tmp1, next)) in
             Binop(tmp1, tr_binop op, r1', r2', l)

         | Stacked k, Register r1', Stacked k2 ->
             reg_use r1';
             let l = add_instr (SetLocal(k, tmp1, next)) in
             let l = add_instr (Binop(tmp1, tr_binop op, r1', tmp1, l)) in
             GetLocal(tmp1, k2, l)

         | Stacked k, Stacked k1, Register r2' ->
             reg_use r2';
             let l = add_instr (SetLocal(k, tmp1, next)) in
             let l = add_instr (Binop(tmp1, tr_binop op, tmp1, r2', l)) in
             GetLocal(tmp1, k1, l)

         | Stacked k, Stacked k1, Stacked k2 ->
             let l = add_instr (SetLocal(k, tmp1, next)) in
             let l = add_instr (Binop(tmp1, tr_binop op, tmp1, tmp2, l)) in
             let l = add_instr (GetLocal(tmp2, k1, l)) in
             GetLocal(tmp1, k2, l)
       end

    | Vips.GetParam(r, s, next) ->
        begin match Hashtbl.find alloc r with
        | Register r' ->
            reg_use r';
            GetParam(r', s, next)
        | Stacked k ->
            let l = add_instr (SetLocal(k, tmp1, next)) in
            GetParam(tmp1, s, l)
        end

    | Vips.Putchar(String s, next) ->
        (* Ne pas lire ce code pour ne pas devenir fou *)
        let code_putchar = 11 in

        let i = ref 0 in
        let ss = List.rev @@ List.flatten @@ List.filter_map (fun e ->
          try
            if !i = 0 && s.[0] = 'n' then begin incr i; Some [Some e] end
            else begin incr i;
              if e.[0] = 'n' then begin
              try
                let r = String.sub e 1 (String.length e - 1) in
                Some [None; Some r]
              with Invalid_argument _ ->
                Some [None]
              end else Some [Some e]
            end
          with _ -> None
          ) (String.split_on_char '\\' s)
        in

        let l = ref next in
        let last = ref None in

        List.iter (function
          Some s ->
            String.iter (fun e ->
              let n = Char.code e in
              l := add_instr (Pop(Mips.a0, !l));
              l := add_instr (Syscall !l);
              l := add_instr (Cst(scod, code_putchar, !l));
              l := add_instr (Cst(Mips.a0, n, !l));
              last := Some (Push(Mips.a0, !l));
              l := add_instr (Option.get !last)
            ) (Utils.List_funcs.rev_string s);
          | None ->
              let n = 10 in
              l := add_instr (Pop(Mips.a0, !l));
              l := add_instr (Syscall !l);
              l := add_instr (Cst(scod, code_putchar, !l));
              l := add_instr (Cst(Mips.a0, n, !l));
              last := Some (Push(Mips.a0, !l));
              l := add_instr (Option.get !last)
        ) ss;

        let ret = match !last with
          | Some e -> e
          | None -> Jump next
        in
        ret

    | Vips.Putchar(Reg r, next) ->
        let code_putchar = 1 in
        let l = add_instr (Pop(Mips.a0, next)) in
        let l = add_instr (Syscall l) in
        let l = begin match Hashtbl.find alloc r with
        | Register r' ->
            reg_use r';
            let l = add_instr (Unop(arg, Move, r', l)) in
            add_instr (Cst(scod, code_putchar, l))
        | Stacked k ->
            let l = add_instr (GetLocal(arg, k, l)) in
            add_instr (Cst(scod, code_putchar, l))
        end in
        Push(Mips.a0, l)

    | Vips.GetGlobal(r, s, next) ->
        begin match Hashtbl.find alloc r with
        | Register r' ->
            reg_use r';
            GetGlobal(r', s, next)
        | Stacked k ->
            let l = add_instr (SetLocal(k, tmp1, next)) in
            GetGlobal(tmp1, s, l)
        end

    | Vips.SetGlobal(s, r, next) ->
        begin match Hashtbl.find alloc r with
        | Register r' ->
            reg_use r';
            SetGlobal(s, r', next)
        | Stacked k ->
            let l = add_instr (SetGlobal(s, tmp1, next)) in
            GetLocal(tmp1, k, l)
        end

    | Vips.Jump next ->
        Jump next

    | Vips.CJump(r, next1, next2) ->
        begin match Hashtbl.find alloc r with
        | Register r' ->
            reg_use r';
            CJump(r', next1, next2)
        | Stacked k ->
            let l = add_instr (CJump(tmp1, next1, next2)) in
            GetLocal(tmp1, k, l)
        end

    | Vips.Write(r1, r2, next) ->
       begin match Hashtbl.find alloc r1, Hashtbl.find alloc r2 with
         | Register r1', Register r2' ->
             reg_use r1';
             reg_use r2';
             Write(r1', r2', next)
         | Register r1', Stacked k2 ->
             reg_use r1';
             let l = add_instr (Write(r1', tmp1, next)) in
             GetLocal(tmp1, k2, l)
         | Stacked k1, Register r2' ->
             reg_use r2';
             let l = add_instr (Write(tmp1, r2', next)) in
             GetLocal(tmp1, k1, l)
         | Stacked k1, Stacked k2 ->
             let l = add_instr (Write(tmp1, tmp2, next)) in
             let l = add_instr (GetLocal(tmp1, k1, l)) in
             GetLocal(tmp2, k2, l)
       end

    | Vips.StaticWrite(r, el, next) ->
        StaticWrite(r, el, next)

    | Vips.Call(r, func, args, _tag, next) ->

        (* Protocole : étape 4 *)
        let retrieve_result = match Hashtbl.find alloc r with
          | Register r' ->
              reg_use r';
              Unop(r', Move, ret, next)
          | Stacked k ->
              SetLocal(k, ret, next)
        in
        let l = add_instr retrieve_result in

        (* restaurer les registres *)
        reg_use_add_params ();
        let l = rest_reg l in

        let d =
          match List.length args with
          | 0 | 1 | 2 | 3 | 4 -> 0
          | x -> x - 4
        in

        let l = add_instr (Unop(sp, Addi (4*d), sp, l)) in

        (* Appel *)
        let l = match func with
          | Vips.FName f -> add_instr (Call(FName f, l))
          | Vips.FPointeur fp ->
              begin match Hashtbl.find alloc fp with
                | Register r' ->
                    reg_use r';
                    add_instr (Call(FPointeur r', l))
                | Stacked k ->
                    let l = add_instr (Call(FPointeur tmp1, l)) in
                    add_instr (GetLocal(tmp1, k, l))
              end
        in
        (* à noter : l'appel va enregistrer l'adresse de retour dans le
           registre $ra *)

        (* Protocole : étape 1 *)
        let i = ref 0 in
        let reg_params = [|Mips.a0;Mips.a1;Mips.a2;Mips.a3|] in

        let rec pass_args args l = match args with
          | [] -> l
          | a::args ->
              let l =
                try
                  let rp = reg_params.(!i) in
                  incr i;
                  match Hashtbl.find alloc a with
                    | Register r' ->
                        add_instr (Unop(rp, Move, r', l))
                    | Stacked k ->
                        add_instr (GetLocal(rp, k, l))
                with Invalid_argument _ ->
                  match Hashtbl.find alloc a with
                    | Register r' ->
                        add_instr (Push(r', l))
                    | Stacked k ->
                        let l = add_instr (Push(tmp1, l)) in
                        add_instr (GetLocal(tmp1, k, l))
              in
              pass_args args l
        in
        let l = pass_args args l in
       (* sauvegarder les registres *)
        let l = save_reg l in

        Jump l

    | Vips.Return r -> (* dans le protocole : 3 *)
       let l = add_instr Return in
       let l = add_instr (Pop(fp, l)) in
       let l = add_instr (Pop(ra, l)) in
       let l = add_instr (Unop(sp, Addi ~-8, fp, l)) in
       let i = match Hashtbl.find alloc r with
         | Register r' -> Unop(ret, Move, r', l)
         | Stacked k   -> GetLocal(ret, k, l)
       in
       i

  in


  Hashtbl.iter
    (fun l i -> Hashtbl.add code l (tr_instr i))
    Vips.(fdef.code);

  (* Dans le protocole : n°2 *)
  let l = add_instr (Unop(sp, Addi (-4 * nb_locals), sp,
                          Vips.(fdef.entry))) in
  let l = add_instr (Unop(fp, Addi 8, sp, l)) in
  let l = add_instr (Push(ra, l)) in
  let entry = add_instr (Push(fp, l)) in
  let name = Vips.(fdef.name) in

  { name; code; entry }

let translate_prog prog = {
    globals = Vips.(prog.globals);
    functions = List.map translate_fdef Vips.(prog.functions)
  }
