let usage_msg = "append [-verbose] <file.kawa> [-o <output>]"

let verbose = ref false

let input_files = ref []

let routput_file = ref ""

let anon_fun filename =
  input_files := filename :: !input_files

let speclist =
  [("-verbose", Arg.Set verbose, "Output debug information");
   ("-o", Arg.Set_string routput_file, "Set output file name")]

let () = Arg.parse speclist anon_fun usage_msg
