(******************************************************************************)
(* Copyright © Joly Clément, 2014                                             *)
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

(* Function to create the tmp file *)
let create_tmp_file ~name =
  Out_channel.create name (* TODO create file in /tmp *)
;;

(* Function to open tmp file *)
let rec init ~tmp =
  (* If file do not exists, create it *)
  let file_exists = (Sys.file_exists tmp) in
    match file_exists with
      | `No -> let file = create_tmp_file ~name:tmp in
          init ~tmp:tmp
      | `Unknown -> begin
          Core_extended.Shell.rm tmp;
          init ~tmp:tmp
        end
      | `Yes -> Yojson.Basic.pretty_to_channel (Out_channel.create tmp) Const.tmp_file_template
;;

(* Verify that the value exist *)
let verify_key_exist ~key entry =
    if entry = key then
        true
    else
        false
;;

(* Stock a value a file in /tmp
   ~target is the target file *)
let stock_tmp ~key ~value ~target =
  let num_value = List.find target ~f:(verify_key_exist ~key:key) in
    num_value
;;

(* Return true if a program is in the rc file *)
let rec is_prog_in_rc list_from_rc_file program = (* TODO restaure ?(list_from_rc_file=rc_content.progs) *)
    match list_from_rc_file with
    (* | None -> is_prog_in_rc program ~liste_from_rc_file:rc_content.progs *)
    | [] -> false
    | hd :: tl -> if hd = program then true else is_prog_in_rc tl program
;;

(*
(* Log when a program has been launched *)
let log program =
    (* Verify the program exist in rc file *)
    let prog_rc = (is_prog_in_rc program) in
    match prog_rc with
    | false -> (* failwith *) "Not in configuration file"
    | true -> "Tmp value" (* TODO delete this *)
    (* let open Tmp_log_t in
    File_com.stock_tmp ~target:tmp_content.cmd ~key:program ~value:1 *)
;;
*)
