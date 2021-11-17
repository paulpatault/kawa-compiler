(**
   Kawa : un petit langage à objets inspiré de Java
 *)

open Utils

type typ =
  | Typ_Void
  | Typ_Int
  | Typ_Bool
  | Typ_Class of string

type binop = Add | Sub | Mul | Div | Lt | Le | Gt | Ge | Eq | Neq | And | Or

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
  | Putchar of print_type list
  | Printf  of string * print_type list
  | If      of expr * seq * seq
  | While   of expr * seq
  | Return  of expr
  | Expr    of expr
  | Set     of mem_access * expr

and print_type =
  | E of expr
  | S of string

and seq = instr list

type method_def = {
    method_name: string;
    code: seq;
    params: (string * typ) list;
    locals: (string * typ) list;
    return: typ;
    tag: string list;
    meth_loc: Loc.position;
  }

type class_def = {
    class_name: string;
    attributes: (string * typ) list;
    methods: method_def list;
    parent: string option;
    class_loc: Loc.position;
  }

type program = {
    classes: class_def list;
    globals: (string * typ) list;
    main: seq;
  }

let mk_prog ?classes ?globals ?main prog =
  {
    classes = Option.value classes ~default:prog.classes;
    globals = Option.value globals ~default:prog.globals;
    main    = Option.value main    ~default:prog.main;
  }

let mk_class_def ?class_name ?attributes ?methods ?parent ?class_loc classe =
  {
    class_name = Option.value class_name ~default:classe.class_name;
    attributes = Option.value attributes ~default:classe.attributes;
    methods    = Option.value methods    ~default:classe.methods;
    parent     = Option.value parent     ~default:classe.parent;
    class_loc  = Option.value class_loc  ~default:classe.class_loc;
  }

let mk_meth_def ?method_name ?code ?params ?locals ?return ?tag ?meth_loc meth =
  {
    method_name = Option.value method_name ~default:meth.method_name;
    code        = Option.value code        ~default:meth.code;
    params      = Option.value params      ~default:meth.params;
    locals      = Option.value locals      ~default:meth.locals;
    return      = Option.value return      ~default:meth.return;
    tag         = Option.value tag         ~default:meth.tag;
    meth_loc    = Option.value meth_loc    ~default:meth.meth_loc;
  }
