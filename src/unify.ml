(******************************************************************************)
(* Copyright © Joly Clément, 2016                                        *)
(*                                                                            *)
(*  leowzukw@oclaunch.eu.org                                                  *)
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

(* Function to remove "\n" and space like characters at the start or the end of
 * a given string. *)
(* XXX Bypassing Core library, which removes this function. There is maybe
 * something like this in Core, should search further. *)
let trim = String.trim;;

open Core.Std;;

(* Function to remove doubled entries, keeping order in a given list. Since the
 * list is a very short one, (a few tens entries), it's cheaper to use a list
 * internally *)
let make_uniq dubbled_entries =
  let seen = ref [] in (* Entries already added *)
  List.(filter dubbled_entries ~f:(fun entry ->
         (exists !seen ~f:(fun in_seen -> in_seen = entry)) |> function
         | false -> (* Entry not already seen, keep it *)
           seen := (entry :: !seen); true
         (* Already kept, discard *)
         | true -> false))
;;

(* Remove doubled or void entries in a list. Commands are cleanup (removing
 * space caracters at the bottom and at the end) *)
(* TODO Test it separatly, reusing tests from edit_command.ml *)
let prettify_cmd cmds =
  let without_lr =
    (* Removing line return, and trailing spaces, at the end or
       at the start of a command *)
    List.filter_map cmds ~f:(fun str ->
           trim str |> function
           | "" ->
             Messages.debug "Trimmed command";
             None
           | s -> Some s)
  in

  (* Remove doubled entries *)
  let unified_rc = make_uniq without_lr in

  (* Display whether duplicates were found *)
  if List.(length unified_rc = length without_lr) then
    Messages.debug "No duplicate found"
  else
    Messages.debug "Duplicate found, removed";

  unified_rc
;;

(* Removing doubled entries (cmds). We need to remove carriage return before
 * deduplicating, since they don't need to be in rc file, and the first one
 * would be kept during deduplication. *)
let prettify rc_file =
  let cmds = rc_file.Settings_v.progs in
  let unique = prettify_cmd cmds in
  (* Store the deduplicated list in new rc_file *)
  {rc_file with Settings_v.progs = unique}
;;

