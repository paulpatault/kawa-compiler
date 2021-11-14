
type position = string * int * int * int

exception TypeError of string

let error ?loc e = match loc with
  | Some (_s, ligne, _d2, _d3) ->
      raise (TypeError (Printf.sprintf "Erreur ligne %d: %s" ligne e))
  | None -> raise (TypeError e)
