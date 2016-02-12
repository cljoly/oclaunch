#!/usr/bin/env coretop
(******************************************************************************)
(* Copyright © Joly Clément, 2016                                             *)
(*                                                                            *)
(*  leowzukw@vmail.me                                                         *)
(*                                                                            *)
(*  Ce logiciel est un programme informatique servant à exécuter              *)
(*  automatiquement des programmes à l'ouverture du terminal.                 *)
(*                                                                            *)
(*  Ce logiciel est régi par la licence CeCILL soumise au droit français et   *)
(*  respectant les principes de diffusion des logiciels libres. Vous pouvez   *)
(*  utiliser, modifier et/ou redistribuer ce programme sous les conditions    *)
(*  de la licence CeCILL telle que diffusée par le CEA, le CNRS et l'INRIA    *)
(*  sur le site "http://www.cecill.info".                                     *)
(*                                                                            *)
(*  En contrepartie de l'accessibilité au code source et des droits de copie, *)
(*  de modification et de redistribution accordés par cette licence, il n'est *)
(*  offert aux utilisateurs qu'une garantie limitée.  Pour les mêmes raisons, *)
(*  seule une responsabilité restreinte pèse sur l'auteur du programme,  le   *)
(*  titulaire des droits patrimoniaux et les concédants successifs.           *)
(*                                                                            *)
(*  A cet égard  l'attention de l'utilisateur est attirée sur les risques     *)
(*  associés au chargement,  à l'utilisation,  à la modification et/ou au     *)
(*  développement et à la reproduction du logiciel par l'utilisateur étant    *)
(*  donné sa spécificité de logiciel libre, qui peut le rendre complexe à     *)
(*  manipuler et qui le réserve donc à des développeurs et des professionnels *)
(*  avertis possédant  des  connaissances  informatiques approfondies.  Les   *)
(*  utilisateurs sont donc invités à charger  et  tester  l'adéquation  du    *)
(*  logiciel à leurs besoins dans des conditions permettant d'assurer la      *)
(*  sécurité de leurs systèmes et ou de leurs données et, plus généralement,  *)
(*  à l'utiliser et l'exploiter dans les mêmes conditions de sécurité.        *)
(*                                                                            *)
(*  Le fait que vous puissiez accéder à cet en-tête signifie que vous avez    *)
(*  pris connaissance de la licence CeCILL, et que vous en avez accepté les   *)
(*  termes.                                                                   *)
(******************************************************************************)

open Core.Std;;
(* TODO:
 * - Tidy exit codes *)

let ignored =
  (* File (space separated) to be ignored, regexp passed to tree command *)
  "src/third-part/ src/color_print.ml \
   src/settings_j.ml src/settings_t.ml src/settings_v.ml \
   src/settings_j.mli src/settings_t.mli src/settings_v.mli \
   src/tmp_biniou_b.ml src/tmp_biniou_t.ml src/tmp_biniou_v.ml \
   src/tmp_biniou_b.mli src/tmp_biniou_t.mli src/tmp_biniou_v.mli \
  " (* The following code prevent strange filename to appear *)
  |> String.split ~on:' '
  |> List.filter_map ~f:(function
         | "" | " " | "  " | "   " | "    " -> None
         | path -> Some ("-e " ^ path ^ " "))
  |> String.concat
;;

(* List ml files, basic regexp, should be enough *)
let list_mlfiles path =
  (* 1st grep: select ocaml files,
   * 2nd grep: remove symlinks and ignored files *)
  sprintf "tree -if %s | grep -e '.*\\.ml$' | grep -v -e '.* -> .*' %s"
    path ignored
  |> (fun cmd -> print_endline cmd; cmd)
  |> Unix.open_process_in
  |> In_channel.input_all
  |> String.split ~on:'\n'
  |> List.filter ~f:(function "" -> false | _ -> true)
;;

(* Call ocp-indent for indentation *)
let ocp_indent file =
  let args = "--inplace" in
  String.concat [ "ocp-indent "; args; " "; file]
  |> Sys.command
  |> function
  | 0 -> printf "File: '%s' ok\n" file
  | error -> printf "Error with file: '%s'; code: %i\n%!" file error; exit 3
;;

let () =
  Sys.argv |> function
    [| _; path |] ->
    list_mlfiles path |> List.iter ~f:ocp_indent;
    printf "Done\n%!";
    exit 0
  | _ -> printf "Usage: %s [directory containing file to indent]\n"
           Sys.executable_name;
    exit 1
;;

