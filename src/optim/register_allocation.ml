open Ast.Vips
open Utils

type color = int
module C = Map.Make(String)
type coloring = color C.t

type location = Register of string | Stacked of int
let registers =
  [| "$t2"; "$t3"; "$t4"; "$t5"; "$t6"; "$t7"; "$t8"; "$t9";
     "$s0"; "$s1"; "$s2"; "$s3"; "$s4"; "$s5"; "$s6"; "$s7" |]

let nb_registers = Array.length registers

let make_interference_graph fdef =
  let _, live_out = Liveness.liveness fdef in

  let graph = ref Graph.G.empty in

  Hashtbl.iter (
    fun _ i -> match i with
      | Cst(r, _, _)
      | Addr(r, _, _)
      | GetGlobal(r, _, _)
      | SetGlobal(_, r, _)
      | GetParam(r, _, _)
      | Putchar(Reg r, _)
      | Assert (r, _, _)
      | CJump(r, _, _)
      | Return r ->
          graph := Graph.add_node r !graph
      | Write(r1, r2, _)
      | Unop(r1, _, r2, _) ->
          graph := Graph.add_node r1 !graph;
          graph := Graph.add_node r2 !graph;
      | Binop(r1, _, r2, r3, _) ->
          graph := Graph.add_node r1 !graph;
          graph := Graph.add_node r2 !graph;
          graph := Graph.add_node r3 !graph;
      | Call(r, _, rl, _, _) ->
          List.iter (fun r -> graph := Graph.add_node r !graph) (r::rl)
      | StaticWrite(_, rl, _) ->
          List.iter (fun r -> graph := Graph.add_node r !graph) rl
      | Jump _ -> ()
      | Putchar (String _, _) -> ()
    ) fdef.code;


  Hashtbl.iter (fun label instr ->
    match instr with
    | Cst(r, _, _) | Addr(r, _, _) | Unop(r, _, _, _) | Binop(r, _, _, _, _) | GetGlobal(r, _, _) | GetParam(r, _, _)
    | Call(r, _, _, _, _) ->
        Graph.S.iter (fun r' ->
          graph := Graph.add_edge r r' (!graph))
        (Graph.S.diff (Hashtbl.find live_out label) (Graph.S.add r Graph.S.empty))
    | Putchar _ | Assert _ | SetGlobal _ | Jump _ | CJump _ | Return _ | Write _ | StaticWrite _ ->
        ()
  ) fdef.code;

  !graph

(* Fonction auxiliaire : choix du prochain nœud *)
let choose_node g =
  let node0 = Int.max_int, "" in
  let f node _ res =
    let deg = Graph.degree node g in
    if deg < fst res then deg, node
    else res in
  let _deg, node = Graph.G.fold f g node0 in
  node

(* Fonction auxiliaire : choix d'une couleur pour un nœud *)
let pick_color x g coloring =
  let neighbors = Graph.find x g in
  let colors = Graph.S.fold (fun elt acc ->
    if C.mem elt coloring then
      (C.find elt coloring)::acc
    else
      acc) neighbors [] in
  let colors = List.sort Stdlib.compare colors in
  let color = List.fold_left (fun acc elt ->
    if elt >= acc then
      elt + 1
    else
      acc) 0  colors in
  color

let rec color g =
  if Graph.G.is_empty g then C.empty
  else
    let node = choose_node g in
    let g' = Graph.remove_node node g in
    let coloration = color g' in
    let couleur = pick_color node g coloration in
    C.add node couleur coloration

let explicit_allocation coloring =
  let a = Hashtbl.create 128 in
  C.iter
    (fun x i -> let r = if i < nb_registers then
                          Register(registers.(i))
                        else
                          Stacked(i-nb_registers)
                in Hashtbl.add a x r)
    coloring;
  a

let max x y =
  if x < y then y else x
let max_color coloring =
  C.fold (fun _ c maxc -> max c maxc) coloring 0

let allocate_function fdef =
  let g = make_interference_graph fdef in
  (* print_string "interference graphe ok\n"; *)
  let coloring = color g in
  (* print_string "coloration ok\n"; *)
  explicit_allocation coloring, max (max_color coloring - nb_registers) 0
