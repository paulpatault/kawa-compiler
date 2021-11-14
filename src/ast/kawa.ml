(**
   Kawa : un petit langage à objets inspiré de Java
 *)

(* Types déclarés pour les attributs, pour les variables, et pour les
   paramètres et résultats des méthodes. *)

open Utils

type typ =
  | Typ_Void
  | Typ_Int
  | Typ_Bool
  | Typ_Class of string

(* Opérateurs binaires *)
type binop = Add | Mul | Lt | Eq

(* Expressions *)

type expr = {
  expr_desc: expr_desc;
  expr_loc : Loc.position;
}

and expr_desc =
  (* Base arithmétique *)
  | Cst    of int
  | Bool   of bool
  | Binop  of binop * expr * expr
  (* Accès à une variable ou un attribut *)
  | Get      of mem_access
  (* Objet courant *)
  | This
  (* Création d'un nouvel objet *)
  | New      of string * expr list
  (* Appel de méthode *)
  | MethCall of expr * string * expr list

(* Accès mémoire : variable ou attribut d'un objet *)
and mem_access =
  | Var   of string
  | Field of expr * string

(* Instructions *)
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
  (* Écriture dans une variable ou un attribut *)
  | Set    of mem_access * expr

and print_type =
  | E of expr
  | C of char

and seq = instr list

(* Définition de méthode

   Syntaxe : method <type de retour> <nom> (<params>) { ... }

   Le corps de la méthode est similaire au corps d'une fonction. *)
type method_def = {
    method_name: string;
    code: seq;
    params: (string * typ) list;
    locals: (string * typ) list;
    return: typ;
  }

(* Définition de classe

   Syntaxe : class <nom de la classe> { ... }
        ou : class <nom de la classe> extends <nom de la classe mère> { ... }

   On considère que toute classe C contient une définition de méthode de nom
   "constructor" et de type de retour void, qui initialise les champs du
   paramètre implicite this. *)
type class_def = {
    class_name: string;
    attributes: (string * typ) list;
    methods: method_def list;
    parent: string option;
  }

(* Programme complet : variables globales, classes, et une séquence
   d'instructions *)
type program = {
    classes: class_def list;
    globals: (string * typ) list;
    main: seq;
  }

(**
   Compilation de Kawa
   ===================

   Représentation des classes et des objets
   ------

   Chaque classe est représentée à l'exécution par un bloc en mémoire appelé
   "descripteur de classe" et contenant
     * un premier champ contenant un pointeur vers le descripteur de la
       classe mère, le cas échéant, et un pointeur nul sinon
     * un champ pour chaque méthode de la classe, contenant un pointeur vers
       la fonction correspondante

   Un objet Kawa est représenté par un pointeur vers un bloc en mémoire, qui
   contient
     * une premier champ contenant un pointeur vers le descripteur de la
       classe de l'objet
     * puis un champ par attribut de la classe


   Traduction des méthodes
   ------

   Un appel de méthode a la forme
     obj.m(a1, ..., aN)
   où
     * [obj] est le paramètre implicite
     * [m] est le nom de la méthode
     * [a1] à [aN] sont les paramètres explicites
   Dans le corps d'une méthode, le mot-clé [this] fait référence au paramètre
   implicite.

   Une méthode Kawa à N arguments explicites est traduite en Pimp en une
   fonction à N+1 arguments, qui attend explicitement l'argument implicite.
   Ainsi un appel Kawa de la forme
     obj.m(a1, ..., aN)
   est traduit en un appel Pimp de la forme
     f(obj, a1, ..., aN)

   Pour éviter les collisions, le nom [f] de la fonction produite combine le
   nom [m] de la méthode avec le nom de la classe dans laquelle cette
   méthode est définie.


   Construction de nouveaux objets
   ------

   Lors de la création d'un nouvel objet avec une expression
     new c(a1, ..., aN)
   où
     * [c] est le nom de la classe à instancier
     * [a1] à [aN] sont les paramètres du constructeur
   on réalise les opérations suivantes.
     1. Allocation du bloc représentant l'objet
     2. Initialisation du premier champ du bloc, avec un pointeur vers
        le descripteur de classe
     3. Appel du constructeur, avec comme paramètres l'objet qui vient d'être
        créé et les paramètres [a1] à [aN]
   Le résultat de cette opération est l'objet créé (représenté par son
   pointeur)

   Supplément en cas d'héritage : on appelle le constructeur de la classe
   mère juste avant l'étape 3.


   Traduction des classes
   ------

   Dans chaque classe on établit une table pour les attributs et une table
   pour les méthodes, donnant pour chaque attribut et pour chaque méthode un
   numéro. Le numéro d'un attribut permet d'accéder à sa valeur dans le bloc
   représentant un objet, et le numéro d'une méthode permet d'accéder à son
   pointeur de fonction dans le descripteur de classe.

   Gestion de l'héritage : lorsqu'une classe [B] hérite d'une classe [A],
   on respecte dans [B] les numéros déjà établis pour [A]. En particulier,
     * les nouveaux attributs de [B] sont numérotés à partir du premier
       numéro non utilisé par les attributs de [A]
     * de même pour les nouvelles méthodes de [B]
     * les méthodes qui existaient dans [A] mais sont redéfinies dans [B]
       conservent le numéro qui était le leur dans [A]

 *)
