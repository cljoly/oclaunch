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

(* Function allowing to set the title of the current terminal windows
 * XXX Maybe better in some lib *)
let set_title new_title =
    (* Use echo command to set term  title *)
    Sys.command (sprintf "echo -en \"\\033]0;%s\\a\"" new_title)
    |> function | 0 -> () | _ -> sprintf "Error while setting terminal title"
    |> Messages.warning
;;

(* Function to return the corresponding command to a number *)
let num_cmd_to_cmd ~cmd_list number =
  (* List.nth return None if out of the list *)
  List.nth cmd_list number
  |> function
      (* If in range of the list, return the corresponding command else return
       * an empty string after displaying error. *)
      | Some x -> set_title x; x
      | None ->
          Messages.ok "All has been launched!";
          Messages.tips "You can reset with '-r'";
          (* Return empty string *)
          ""
;;

(* Function to determinate what is the next command to
 * execute. It takes the current number from tmp file. *)
let what_next ~cmd_list =
  let tmp_file = Tmp_file.init () in
  num_cmd_to_cmd ~cmd_list:cmd_list tmp_file.Tmp_biniou_t.number
;;

(* Display an error message if command can't run
 * if 0 status, do nothing
 * else display status number *)
let display_result command status =
    match status with
    | 0 -> (* No problem, do nothing *) ()
    | _ -> (* Problem occur,  display it *)
            sprintf "Problem while running: '%s'\nExited with code: %i\n"
            command status
    |> Messages.warning
;;

(* Execute some command and log it *)
let execute ?(display=true) cmd =
    Tmp_file.log ~func:((+) 1) ();
    if display then
        Messages.ok cmd;
    (* We can remove lock file since number in tmp_file has been incremented *)
    Lock.remove ();
    Sys.command cmd
    |> display_result cmd (* Make it settable in rc file *)
;;
