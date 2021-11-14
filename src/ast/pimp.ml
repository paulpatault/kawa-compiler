type unop = Read | Alloc | Dec of int
type binop = Add | Mul | Lt | Le | Gt | Ge | Eq | Neq | And | Or

type expression =
  | Cst   of int
  | Bool  of bool
  | Var   of string
  | Unop  of unop * expression
  | Binop of binop * expression * expression
  | Call  of func * expression list
  | Addr  of string
  | Seq   of sequence * expression

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
  | Write   of expression * expression
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
