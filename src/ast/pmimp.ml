type unop = Addi of int | Subi of int | ShiftL of int | Read | Alloc | Dec of int | Not

type binop = Add | Sub | Mul | Div | Lt | Le | Eq | Neq | And | Or

type expression =
  | Cst   of int
  | Var   of string
  | Addr  of string
  | Unop  of unop * expression
  | Binop of binop * expression * expression
  | Call  of string * expression list * Pimp.tag list
  | Seq   of sequence * expression
  | CallPointeur of expression * expression list * Pimp.tag list

and instruction =
  | Putchar of print_type
  | Set     of string * expression
  | If      of expression * sequence * sequence
  | While   of expression * sequence
  | Return  of expression
  | Expr    of expression
  | Write   of expression * expression
  | StaticWrite of string * string list

and print_type =
  | PExpr of expression
  | PString of string

and sequence = instruction list

type function_def = {
  name: string;
  code: sequence;
  params: string list;
  locals: string list;
}

type program = {
  functions: function_def list;
  globals: string list;
}

(**
   Smart constructors.

   Un appel [mk_add e1 e2] construit une expression équivalente à

     Binop(Add, e1, e2)

   mais tire parti lorsque c'est possible des formes de e1 et e2 pour
   produire une expression plus simple.

   Il faudra encore construire des fonctions équivalentes pour les
   autres opérations arithmétiques.
 *)
let mk_add e1 e2 =
  match e1, e2 with
  | Cst n1, Cst n2 ->
      Cst (n1 + n2)
  | Cst n, e | e, Cst n ->
      if n = 0 then e
      else Unop(Addi n, e)
  | e1', e2' ->
      Binop(Add, e1', e2')

let mk_sub e1 e2 =
  match e1, e2 with
  | Cst n1, Cst n2 ->
      Cst (n1 - n2)
  (* | Cst n, e ->
      if n = 0 then e
      else Unop(Addi n, e) *)
  | e, Cst n ->
      if n = 0 then e
      else Unop(Subi n, e)
  | e1', e2' ->
      Binop(Sub, e1', e2')

(* let log2 x = log x /. log 2. *)

let log2 n =
  if n < 2 then -1 else
  let rec aux x acc =
    if x > n then -1
    else if x = n then acc
    else aux (x * 2) (acc + 1)
  in
  aux 1 0

let mk_mul e1 e2 =
  match e1, e2 with
  | Cst n1, Cst n2 ->
      Cst (n1 * n2)
  | Cst n, e | e, Cst n ->
      let l = log2 n in
      if l = -1
      then
        if n = 0 then
          Cst 0
        else if n = 1 then
          Cst n
        else
          Binop(Mul, e, Cst n)
      else Unop(ShiftL l, e)
  | e1', e2' ->
      Binop(Mul, e1', e2')

let mk_lt e1 e2 =
  match e1, e2 with
  | Cst n1, Cst n2 ->
      if n1 < n2 then Cst 1
      else Cst 0
  | e1', e2' ->
      Binop(Lt, e1', e2')

let mk_le e1 e2 =
  match e1, e2 with
  | Cst n1, Cst n2 ->
      if n1 <= n2 then Cst 1
      else Cst 0
  | e1', e2' ->
      Binop(Le, e1', e2')

let mk_eq e1 e2 =
  match e1, e2 with
  | Cst n1, Cst n2 ->
      if n1 = n2 then Cst 1
      else Cst 0
  | e1', e2' ->
      Binop(Eq, e1', e2')

let mk_neq e1 e2 =
  match e1, e2 with
  | Cst n1, Cst n2 ->
      if n1 <> n2 then Cst 1
      else Cst 0
  | e1', e2' ->
      Binop(Neq, e1', e2')

let mk_or e1 e2 =
  match e1, e2 with
  | Cst n1, Cst n2 ->
      if n1 <> 0 then Cst 1
      else if n2 <> 0 then Cst 1
      else Cst 0
  | Cst n, e ->
      if n = 0 then e
      else Cst 1
  | e1', e2' ->
      Binop(Or, e1', e2')

let mk_and e1 e2 =
  match e1, e2 with
  | Cst n1, Cst n2 ->
      if n1 <> 0 then
        if n2 <> 0 then Cst 1
        else Cst 0
      else Cst 0
  | Cst n, e ->
      if n = 0 then Cst 0
      else e
  | e1', e2' ->
      Binop(And, e1', e2')
