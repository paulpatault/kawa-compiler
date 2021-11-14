{

  open Lexing
  open Kawaparser

    let keyword_or_ident =
    let h = Hashtbl.create 17 in
    List.iter (fun (s, k) -> Hashtbl.add h s k)
      [ "putchar",  PUTCHAR;
        "if",       IF;
        "else",     ELSE;
        "while",    WHILE;
        "true",     BOOL true;
        "false",    BOOL false;
        "return",   RETURN;
        "int",      TYP_INT;
        "bool",     TYP_BOOL;
        "void",     TYP_VOID;
        "class",    CLASS;
        "extends",  EXTENDS;
        "new",      NEW;
        "this",     THIS;
        "method",   METHOD;
        "var",      VAR;
        "attribute", ATTRIBUTE;
        "main",     MAIN;
      ] ;
    fun s ->
      try  Hashtbl.find h s
      with Not_found -> IDENT(s)

}

let digit = ['0'-'9']
let number = ['-']? digit+
let alpha = ['a'-'z' 'A'-'Z']
let ident = ['a'-'z' 'A'-'Z' '_'] (alpha | '_' | digit)*

rule token = parse
  | ['\n']
      { new_line lexbuf; token lexbuf }
  | [' ' '\t' '\r']+
      { token lexbuf }
  | "//" [^ '\n']* "\n"
      { new_line lexbuf; token lexbuf }
  | "/*"
      { comment lexbuf; token lexbuf }
  | number as n
      { CST(int_of_string n) }
  | ident as id
      { keyword_or_ident id }
  | "'" (_ as c) "'"
      { CHAR(c) }
  | ";"
      { SEMI }
  | "="
      { SET }
  | "+"
      { PLUS }
  | "*"
      { STAR }
  | "<"
      { LT }
  | "=="
      { EQ }
  | "("
      { LPAR }
  | ")"
      { RPAR }
  | "{"
      { BEGIN }
  | "}"
      { END }
  | ","
      { COMMA }
  | "."
      { DOT }
  | _
      { failwith ("Unknown character : " ^ (lexeme lexbuf)) }
  | eof
      { EOF }

and comment = parse
  | "*/"
      { () }
  | _
      { comment lexbuf }
  | eof
      { failwith "unfinished comment" }
