(**
   PIMP = IMP + pointeurs

   Partie I. Syntaxe abstraite
 *)

  (* Opérations unaires : lecture en mémoire, et allocation *)
type unop = Read | Alloc | Dec of int
type binop = Add | Mul | Lt | Eq

type expression =
  | Cst   of int
  | Bool  of bool
  | Var   of string
  | Unop  of unop * expression
  | Binop of binop * expression * expression
  (* Appel de fonction *)
  | Call  of func * expression list
  (* Récupération de l'adresse d'une fonction *)
  | Addr  of string
  (* Inclusion d'une séquence d'instructions dans une expression *)
  | Seq   of sequence * expression

(* Une fonction est désignée soit par un identifiant, comme dans IMP,
   soit par un pointeur. *)
and func =
  | FName of string
  | FPointer of expression

and instruction =
  | Putchar  of print_type
  | Set     of string * expression
  | If      of expression * sequence * sequence
  | While   of expression * sequence
  | Return  of expression
  | Expr    of expression
  (* Écriture en mémoire *)
  | Write   of expression * expression
  (* Écriture dans .data *)
  | StaticWrite   of string * string list

and print_type =
  | PExpr of expression
  | PAscii of int

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
