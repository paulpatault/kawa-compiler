type tag = Optim | Static

type unop = Read | Alloc | Dec of int | Not
type binop = Add | Sub | Mul | Div | Lt | Le | Gt | Ge | Eq | Neq | And | Or

type expression =
  | Cst   of int
  | Bool  of bool
  | Var   of string
  | Unop  of unop * expression
  | Binop of binop * expression * expression
  | Call  of func * expression list * tag list
  | Addr  of string
  | Seq   of sequence * expression

and func =
  | FName of string
  | FPointer of expression

and instruction =
  | Assert  of expression * int
  | Putchar of print_type
  | Set     of string * expression
  | If      of expression * sequence * sequence
  | While   of expression * sequence
  | Return  of expression
  | Expr    of expression
  | Write   of expression * expression
  | StaticWrite   of string * string list

and print_type =
  | PExpr of expression
  | PString of string

and sequence = instruction list

type function_def = {
  name: string;
  code: sequence;
  params: string list;
  locals: string list;
  tag: tag list
}

type program = {
  functions: function_def list;
  globals: string list;
}
