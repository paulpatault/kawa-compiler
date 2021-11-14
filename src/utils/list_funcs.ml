let replace_assoc l k v =
  List.fold_left
    (fun acc (k', v') ->
      if k' = k then (k, v) :: acc
      else (k', v') :: acc
    )
    [] l
  |> List.rev
