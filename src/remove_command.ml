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

(* Module to remove commands without editing the rc file directly *)

(* Function remove nth command in the rc_file, returning the removed one and the
 * new list *)
let remove current_list n =
    let removed = ref "" in
    (* The list without the nth item *)
    let new_list = List.filteri current_list ~f:(fun i _ ->
        if i <> n then
            (* If it is not nth, return true *)
            true
        else
            begin
                (* If it is nth, ie the command to be removed, store it and return
                 * false, to remove the corresponding item *)
                removed := List.nth_exn current_list i;
                false
            end
    ) in
    ( !removed, new_list )
;;

(* Function which add the commands (one per line) ridden on stdin to the rc
 * file, and then display th new configuration *)
let run ~(rc:File_com.t) n_to_remove =
    (* Get actual list of commands *)
    let actual_list = rc.Settings_t.progs in
    (* Get nth *)
    let nth = Option.value n_to_remove
        ~default:((List.length actual_list) - 1) in
    (* Remove the nth command, after display it *)
    let removed,new_list = remove actual_list nth in
    sprintf "Removing: %s\n" removed
    |> Messages.warning;
    (* Write new list to rc file *)
    let updated_rc = { rc with Settings_t.progs = new_list } in
    File_com.write updated_rc;
    (* Display the result *)
    let reread_rc = File_com.init_rc () in
    List_rc.run ~rc:reread_rc ()
;;
