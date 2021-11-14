type register = string
type label = string

type unop  =
  | Move | Alloc | Read
  | Addi   of int
  | Subi   of int
  | ShiftL of int
  | Dec    of int

type binop = Add | Sub | Mul | Lt | Le | Eq

type instr =
  | Cst         of register * int * label
  | Addr        of register * string * label
  | Unop        of register * unop * register * label
  | Binop       of register * binop * register * register * label
  | GetGlobal   of register * string * label
  | SetGlobal   of string * register * label
  | GetParam    of register * int * label
  | Jump        of label
  | CJump       of register * label * label
  | GetLocal    of register * int * label
  | SetLocal    of int * register * label
  | Call        of func * label
  | Return
  | Push        of register * label
  | Pop         of register * label
  | Write       of register * register * label
  | StaticWrite of string * string list * label
  | Syscall     of label

and func =
  | FName of string
  | FPointeur of register

type function_def = {
    name: string;
    code: (string, instr) Hashtbl.t;
    entry: label;
  }

type prog = {
    globals: string list;
    functions: function_def list;
  }

