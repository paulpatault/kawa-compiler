open Format
open Kawadir
open Trads
open Printer
open Optim
open Ast
open Utils.Args

let append_stdlib main_prog =
  let file = "stdlib/stdlib.kawa" in
  let c  = open_in file in
  let lb = Lexing.from_channel c in
  let prog = Kawadir.Kawaparser.program Kawadir.Kawalexer.token lb in
  close_in c;
  assert (prog.globals = []);
  assert (prog.main = []);
  Kawa.mk_prog main_prog ~classes:Kawa.(prog.classes @ main_prog.classes)


let () =
  let file = List.nth !input_files 0 in
  let c  = open_in file in
  let lb = Lexing.from_channel c in
  let prog = Kawaparser.program Kawalexer.token lb in
  close_in c;

  let prog = append_stdlib prog in

  Kawa_type_checker.typ_prog prog ~file;
  print_endline "[OK] kawa  -> well typed";

  let prog_annoted = Kawa_annot.annot_prog prog in

  (* PIMP *)
  let pimp = Kawa2pimp.tr_prog prog_annoted in
  if !verbose then begin
    let output_file = (Filename.chop_suffix file ".kawa") ^ ".pimp" in
    let out = open_out output_file in
    Pimppp.pp_program pimp out;
    close_out out;
  end;
  print_endline "[OK] kawa  -> pimp";

  (* PIMP -> PMIMP *)
  let pmimp = Pimp2pmimp.isel_prog pimp in
  if !verbose then begin
    let output_file = (Filename.chop_suffix file ".kawa") ^ ".pmimp" in
    let out = open_out output_file in
    Pmimppp.pp_program pmimp out;
    close_out out;
  end;
  print_endline "[OK] pimp  -> pmimp";

  (* PMIMP -> VIPS *)
  let vips = Pmimp2vips.translate_prog pmimp in
  if !verbose then begin
    let output_file = (Filename.chop_suffix file ".kawa") ^ ".vips" in
    let out = open_out output_file in
    Vipspp.pp_program vips out;
    close_out out;
  end;
  print_endline "[OK] pmimp -> vips";

  (* VIPS -> VIPSOPT *)
  Deadwriteselimination.dwe_prog vips;
  if !verbose then begin
    let output_file = (Filename.chop_suffix file ".kawa") ^ ".vipsopt" in
    let out = open_out output_file in
    Vipspp.pp_program vips out;
    close_out out;
  end;
  print_endline "[OK] vips  -> vipsopt";

  (* VIPS -> GIPS *)
  let gips = Vips2gips.translate_prog vips in
  if !verbose then begin
    let output_file = (Filename.chop_suffix file ".kawa") ^ ".gips" in
    let out = open_out output_file in
    Gipspp.pp_program gips out;
    close_out out;
  end;
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
  let output_file =
    if !routput_file <> "" then
      !routput_file
    else
      (Filename.chop_suffix file ".kawa") ^ ".asm"
  in
  let out = open_out output_file in
  let outf = formatter_of_out_channel out in
  Mips.print_program outf asm;
  pp_print_flush outf ();
  close_out out;
  print_endline "[OK] gips  -> mips";

  exit 0
