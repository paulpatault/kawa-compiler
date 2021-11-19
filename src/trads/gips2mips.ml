open Ast
open Gips
open Mips

exception Brk_fdef of Gips.function_def

let translate_fdef fdef =
  let vus = Hashtbl.create 32 in

  let rec translate_instr = function
    | Cst(r, n, next) ->
        li r n
        @@ translate_label next

    | Addr(r, s, next) ->
        la r s
        @@ translate_label next

    | Assert (_, next) ->
        (* seq r r zero
        beqz  *)
        (* beqz r next2
        @@ translate_label next1
        @@ translate_label next2 *)
        translate_label next

    | Unop(r, unop, r1, next) ->
        begin match unop with
        | Addi n ->
            addi r r1 n
        | Subi n ->
            subi r r1 n
        | ShiftL n ->
            sll r r1 n
        | Move ->
            move r r1
        | Not ->
            (* si r1 = 0 alors 1 sinon 0 *)
            seq r r1 zero
        | Read ->
            lw r 0 r1
        | Dec n ->
            lw r n r1
        | Alloc ->
            (* push a0 *)
            sw a0 0 sp @@ subi sp sp 4
            (* donner le parametre *)
            @@ move a0 r1
            (* code de sbrk *)
            @@ li v0 9
            (* appel de sbrk*)
            @@ syscall
            (* pointeur renvoyé par sbrk *)
            @@ move r v0
            (* pop a0 *)
            @@ addi sp sp 4 @@ lw a0 0 sp
        end
        @@ translate_label next

    | Binop(r, binop, r1, r2, next) ->
        let op = begin match binop with
        | Add -> add
        | Sub -> sub
        | Mul -> mul
        | Div -> div
        | Lt  -> slt
        | Le  -> sle
        | Eq  -> seq
        | Neq -> sne
        | And -> and_
        | Or  -> or_
        end in
        op r r1 r2 @@ translate_label next

    | GetGlobal(r, n, next) ->
        la r n
        @@ lw r 0 r
        @@ translate_label next

    | SetGlobal(n, r, next) ->
        la t1 n
        @@ sw r 0 t1
        @@ translate_label next

    | GetParam(r, n, next) ->
        begin match n with
        | 0 -> move r a0
        | 1 -> move r a1
        | 2 -> move r a2
        | 3 -> move r a3
        | _ -> lw r (4 * (n-1)) sp
        end
        @@ translate_label next

    | Jump(next) ->
        translate_label next

    | CJump(r, next1, next2) ->
        beqz r next2
        @@ translate_label next1
        @@ translate_label next2

    | GetLocal(r, n, next) ->
        let dec = -4 * (n + 1) in
        lw r dec fp
        @@ translate_label next

    | SetLocal(n, r, next) ->
        let dec = -4 * (n + 1) in
        sw r dec fp
        @@ translate_label next

    | Call(FName f, next) ->
        jal f
        @@ translate_label next

    | Call(FPointeur fp, next) ->
        jalr fp
        @@ translate_label next

    | Return ->
        jr ra

    | Push(r, next) ->
        sw r 0 sp
        @@ subi sp sp 4
        @@ translate_label next

    | Pop(r, next) ->
        addi sp sp 4
        @@ lw r 0 sp
        @@ translate_label next

    | Syscall(next) ->
        syscall @@ translate_label next

    | Write(r1, r2, next) ->
        sw r2 0 r1
        @@ translate_label next

    | StaticWrite(_, _, _next) ->
        (* cas dans lequel on ne devrait pas arriver *)
        assert false
        (* translate_label next *)

  and translate_label l =
    if Hashtbl.mem vus l then
      b l
    else begin
      try
        Hashtbl.add vus l ();
        label l
        @@ translate_instr (Hashtbl.find fdef.code l)
      with Not_found -> (
        Printf.printf "qyoi ? -> %s\n" l;
        exit 1
        )
    end
  in

  label fdef.name @@ translate_label fdef.entry

let translate_program prog =
    let init =
       beqz  a0 "init_end"
    @@ lw    a0 0 a1
    @@ jal   "atoi"
    @@ label "init_end"
    @@ sw    v0 0 sp
    @@ subi  sp sp 4
    @@ jal   "main"
    @@ li    v0 10
    @@ syscall
  and built_ins =
    comment "built-in atoi"
    @@ label "atoi"
    @@ li    v0 0
    @@ label "atoi_loop"
    @@ lbu   t0 0 a0
    @@ beqz  t0 "atoi_end"
    @@ addi  t0 t0 (-48)
    @@ bltz  t0 "atoi_error"
    @@ bgei  t0 10 "atoi_error"
    @@ muli  v0 v0 10
    @@ add   v0 v0 t0
    @@ addi  a0 a0 1
    @@ b     "atoi_loop"
    @@ label "atoi_error"
    @@ li    v0 10
    @@ syscall
    @@ label "atoi_end"
    @@ jr    ra
  in

  let function_codes = List.fold_right
    (fun fdef code ->
      if fdef.name <> "Init_func" then
        translate_fdef fdef @@ code
      else
        code)
    prog.functions nop
  in
  let text = init @@ function_codes @@ built_ins
  and data = List.fold_right
    (fun id code -> label id @@ dword [0] @@ code)
    prog.globals nop
  in

  let data2 =
    let finit =
      try
        List.iter (fun fdef ->
          if fdef.name = "Init_func" then
            raise (Brk_fdef fdef)
        ) prog.functions;
        assert false
      with Brk_fdef fdef -> fdef
    in

    let a = ref Nop in
    Hashtbl.iter (fun _str instr ->
      match instr with
      | StaticWrite(s, sl, _) ->
          let e = List.fold_left (fun acc e -> acc @@ (ins ".word %s" e)) (label s) sl in
          a := C(e,!a);
      | _ -> ()
    ) finit.code;
    !a
  in
  let data = C (data, data2) in

  { text; data }
