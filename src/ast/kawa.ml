(**
   Kawa : un petit langage à objets inspiré de Java
 *)

open Utils

type typ =
  | Typ_Void
  | Typ_Int
  | Typ_Bool
  | Typ_Class of string

type binop = Add | Mul | Lt | Le | Gt | Ge | Eq | Neq | And | Or

type expr = {
  expr_desc: expr_desc;
  expr_loc : Loc.position;
}

and expr_desc =
  | Cst    of int
  | Bool   of bool
  | Binop  of binop * expr * expr
  | Get      of mem_access
  | This
  | New      of string * expr list
  | MethCall of expr * string * expr list

and mem_access =
  | Var   of string
  | Field of expr * string

type instr = {
  instr_desc: instr_desc;
  instr_loc: Loc.position;
}

and instr_desc =
  | Putchar  of print_type
  | If     of expr * seq * seq
  | While  of expr * seq
  | Return of expr
  | Expr   of expr
  | Set    of mem_access * expr

and print_type =
  | E of expr
  | C of char

and seq = instr list

type method_def = {
    method_name: string;
    code: seq;
    params: (string * typ) list;
    locals: (string * typ) list;
    return: typ;
    tag: string option;
  }

type class_def = {
    class_name: string;
    attributes: (string * typ) list;
    methods: method_def list;
    parent: string option;
  }

type program = {
    classes: class_def list;
    globals: (string * typ) list;
    main: seq;
  }
