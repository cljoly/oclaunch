(******************************************************************************)
(* Copyright © Joly Clément, 2014-2015                                        *)
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

(* Module to edit command without editing the rc file directly *)

(* Function to remove empty element in a list *)
let epur =
  Unify.prettify_cmd
;;

(* Function to create a new list augmented by some commands *)
(* TODO Factorise this *)
let new_list current_list position new_items =
    (* If a number is given, add commands after position n by
    splitting the list and concatenating all. List.split_n works like this :
        * #let l1 = [1;2;3;4;5;6] in
        * # List.split_n l1 2;;
        * - : int list * int list = ([1; 2], [3; 4; 5; 6]) *)
    let l_begin,l_end = List.split_n current_list position in
    List.concat [ l_begin ; new_items ; l_end ]
;;


(* Concat edited item, to have a proper list to display
    * If only one element, return "elt".
    * If more than one "\nelt1\nelt2\nelt3\n" *)
let gen_modification items =
    let r = "\n" in
    epur items
    |> (function
        | [] -> ""
        (* Only one element *)
        | element :: [] -> element
        (* The list as more than two elements *)
        | items ->
                let msg = String.concat ~sep:r items in
                String.concat [ r ; msg ; r ])
;;

(* Function which get the nth element, put it in a file, let the user edit it,
 * and then remplace with the new result *)
let rec run ~(rc:File_com.t) position =
    (* Current list of commands *)
    let current_list = rc.Settings_t.progs in

    (* Creating tmp file, for editing *)
    let tmp_filename = [
        "/tmp/oc_edit_" ;
        (Int.to_string (Random.int 100_000)) ;
        ".txt" ;
    ] in
    let tmp_edit = String.concat tmp_filename in
    (* Remove item to be edited *)
    let original_command,shorter_list =
      Remove_command.remove current_list position
    in
    Out_channel.write_all tmp_edit original_command;


    (* Edit file *)
    let edit = String.concat [ Lazy.force Const.editor ; " " ; tmp_edit ] in
    Messages.debug edit;
    Sys.command edit
    |> (function
        0 -> ()
        | n -> sprintf "Error while running %s: error code %i" edit n
        |> Messages.warning);

    (* Reading and applying the result *)
    let new_commands = In_channel.read_lines tmp_edit |> epur in
    let cmd_list = new_list shorter_list position new_commands in
    let updated_rc = { rc with Settings_t.progs = cmd_list} in
    File_com.write updated_rc;
    (* Display the result, only if modified *)
    let new_cmd_mod = gen_modification new_commands in
    (* We are doing things in this order to avoid multiple listing of rc file
     * when reediting. *)
    if ( original_command = new_cmd_mod )
    then (* Nothing change, try reediting *)
      begin
        let open Messages in
        warning "Nothing changed.";
        confirm "Do you want to reedit?"
        |> function
          | Yes -> run ~rc position
          | No -> ()
      end

    else (* Display summary of changes *)
      begin
        sprintf "'%s' -> '%s'\n" original_command new_cmd_mod |> Messages.ok;
        (* Display new rc file *)
        let reread_rc = File_com.init_rc () in
        List_rc.run ~rc:reread_rc ()
      end;
;;
