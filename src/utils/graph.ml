module G = Map.Make(String)
module S = Set.Make(String)
type set = S.t
(* graphe : association entre identifiant de nœud et
   ensemble de nœuds voisins *)
type graph = set G.t
type node = string

(* find: node -> graph -> set *)
let find (x:node) (g:graph): set =
  match G.find_opt x g with
  | None -> S.empty
  | Some s -> s

(* degree: node -> graph -> int *)
let degree (x:node) (g:graph): int =
  S.cardinal (find x g)

(* add_node: node > graph -> graph *)
let add_node (x:node) (g:graph): graph =
  G.add x S.empty g

(* update_node: node -> (set -> set) -> graph -> graph *)
let update_node (x:node) (f:set -> set) (g:graph): graph =
  G.add x (f (find x g)) g

(* add_edge: node -> node -> graph -> graph *)
let add_edge (x:node) (y:node) (g:graph): graph =
  update_node x (S.add y) g
  |> update_node y (S.add x)

(* remove_node: node -> graph -> graph *)
let remove_node (x:node) (g:graph): graph =
  S.fold (fun y -> update_node y (S.remove x)) (G.find x g) g
  |> G.remove x

