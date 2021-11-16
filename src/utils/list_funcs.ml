let replace_assoc l k v =
  List.fold_left
    (fun acc (k', v') ->
      if k' = k then (k, v) :: acc
      else (k', v') :: acc
    )
    [] l
  |> List.rev


let rev_string s =
  let seq = String.to_seq s in
  let l = List.of_seq seq in
  let l = List.rev l in
  let seq = List.to_seq l in
  String.of_seq seq
