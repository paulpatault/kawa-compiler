type position = string * int * int * int

exception TypeError of string

let error ?loc ?file e =
  let f = Option.value file ~default:"file.kawa" in
  match loc with
  | Some (_s, ligne, _d2, _d3) ->
      Ocamlog.enable_decorations ();
      Ocamlog.print Error e ~loc:(f, string_of_int ligne);
      exit 1
  | None -> raise (TypeError e)
