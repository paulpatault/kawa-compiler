type register = string

let new_reg =
  let count = ref 0 in
  fun () -> incr count;
    Printf.sprintf "vreg_%i" !count

type label = string

type unop  =
  | Move | Alloc | Read
  | Addi   of int
  | Subi   of int
  | ShiftL of int
  | Dec    of int

type binop = Add | Sub | Mul | Lt | Le | Eq

type instr =
  | Cst          of register * int * label
  | Addr         of register * string * label
  | Unop         of register * unop * register * label
  | Binop        of register * binop * register * register * label
  | GetGlobal    of register * string * label
  | SetGlobal    of string * register * label
  | GetParam     of register * int * label
  | Putchar      of print_type * label
  | Jump         of label
  | CJump        of register * label * label
  | Call         of register * func * register list * label
  (* | CallPointeur of register * register * register list * label *)
  | Return       of register
  | Write        of register * register * label
  | StaticWrite  of string * string list * label

and print_type =
  | Reg of register
  | Ascii of int

and func =
  | FName     of string
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

