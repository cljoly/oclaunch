(******************************************************************************)
(* Copyright © Joly Clément, 2016                                        *)
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

(* Removing doubled entries (cmds). We need to remove carriage return before
 * deduplicating, since they don't need to be in rc file, and the first one
 * would be kept during deduplication. *)
let pretty rc_file =
  let cmds = rc_file.Settings_v.progs in
  let without_lr = (* Removing line return, and trailing spaces *)
    List.filter_map cmds ~f:(fun str ->
      trim str |> function
        | "" ->
          Messages.debug "Trimmed command";
          None
        | s -> Some s)
  in
  let unique = make_uniq without_lr in
  (* If there is the same number of element, each one is present only once. *)
  if List.(length unique = length without_lr) then
    begin
      Messages.debug "No duplicate found";
      unique
    end
  else
    begin
      Messages.debug "Duplicate found, removed";
      unique
    end
;;

