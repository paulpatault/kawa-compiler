open Format
open Kawadir
open Trads
open Printer
open Optim
open Ast

let () =

  let file = Sys.argv.(1) in
  let c  = open_in file in
  let lb = Lexing.from_channel c in
  let prog = Kawaparser.program Kawalexer.token lb in
  close_in c;

  Kawa_type_checker.typ_prog prog;
  print_endline "[OK] kawa  -> well typed";

  (* PIMP *)
  let pimp = Kawa2pimp.tr_prog prog in
  let output_file = (Filename.chop_suffix file ".kawa") ^ ".pimp" in
  let out = open_out output_file in
  Pimppp.pp_program pimp out;
  close_out out;
  print_endline "[OK] kawa  -> pimp";

  (* PIMP -> PMIMP *)
  let pmimp = Pimp2pmimp.isel_prog pimp in
  let output_file = (Filename.chop_suffix file ".kawa") ^ ".pmimp" in
  let out = open_out output_file in
  Pmimppp.pp_program pmimp out;
  close_out out;
  print_endline "[OK] pimp  -> pmimp";

  (* PMIMP -> VIPS *)
  let vips = Pmimp2vips.translate_prog pmimp in
  let output_file = (Filename.chop_suffix file ".kawa") ^ ".vips" in
  let out = open_out output_file in
  Vipspp.pp_program vips out;
  close_out out;
  print_endline "[OK] pmimp -> vips";

  (* VIPS -> VIPSOPT *)
  Deadwriteselimination.dwe_prog vips;
  let output_file = (Filename.chop_suffix file ".kawa") ^ ".vipsopt" in
  let out = open_out output_file in
  Vipspp.pp_program vips out;
  close_out out;
  print_endline "[OK] vips  -> vipsopt";

  (* VIPS -> GIPS *)
  let gips = Vips2gips.translate_prog vips in
  let output_file = (Filename.chop_suffix file ".kawa") ^ ".gips" in
  let out = open_out output_file in
  Gipspp.pp_program gips out;
  close_out out;
  print_endline "[OK] vips  -> gips";

  (* GIPS -> GIPSOPT *)
  (* let gips = Gips2gipsopt.translate_prog gips in
  print_string "gips to gipsopt ok\n";
  let output_file = (Filename.chop_suffix file ".kawa") ^ ".gipsopt" in
  let out = open_out output_file in
  Gipspp.pp_program gips out;
  close_out out; *)


  (* GIPS -> MIPS *)
  let asm = Gips2mips.translate_program gips in
  let output_file = (Filename.chop_suffix file ".kawa") ^ ".asm" in
  let out = open_out output_file in
  let outf = formatter_of_out_channel out in
  Mips.print_program outf asm;
  pp_print_flush outf ();
  close_out out;
  print_endline "[OK] gips  -> mips";

  exit 0
