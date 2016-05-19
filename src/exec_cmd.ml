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

(* Type to give a more accurate representation of the program *)
type state =
  | Empty (* Empty rc file *)
  | Finish (* everything was launched *)
  | A of string (* There is this command to launch *)
;;

(* Function allowing to set the title of the current terminal windows
 * XXX Maybe better in some lib *)
let set_title new_title =
  (* Use echo command to set term  title *)
  Sys.command (sprintf "echo -en \"\\033]0;%s\\a\"" new_title)
  |> function
  | 0 -> ()
  | _ -> sprintf "Error while setting terminal title" |> Messages.warning
;;

(* Function to return the less launched command, at least the first one *)
(* Log is a list of entry (commands) associated with numbers *)
let less_launched (log : (string * int) list) =
  let open Option in
  let max = Const.default_launch in (* Number of launch, maximum *)
  (* Return smallest, n is the smaller key, if there are some entries *)
  match log with
  | [] -> Empty
  | _ ->
    let entries_by_number = List.Assoc.inverse log in
    List.min_elt ~cmp:(fun (n,_) (n',_) -> Int.compare n n') entries_by_number
    |> fun smallest ->
    bind smallest (fun (min, cmd) -> some_if (min < max) cmd)
    |> function None -> Finish | Some entry -> A entry
;;

(* Function to get the number corresponding to the next command to launch (less
 * launched) *)
let less_launched_num log =
  (* Debug *)
  Messages.debug "less_launched_num: LOG:";
  Tools.spy1_log log

  (* Function to return nothing (None) when max launch number is reached, Some
   * number otherwise *)
  |> List.filter_mapi ~f:(fun entry_number ( _, launch_number ) ->
         if launch_number >= Const.default_launch
         then None
         else Some ( entry_number, launch_number ))
  (* Find the less launched by sorting and taking the first *)
  |> List.sort
       ~cmp:(fun ( _, launch_number1 ) ( _, launch_number2 ) ->
              Int.compare launch_number1 launch_number2)
  |> List.hd
  |> function
  | Some ( entry_number, launch_number ) ->
    launch_number |> sprintf "Launch number found: %i" |> Messages.debug;
    Messages.debug "Return launch number (printed bellow):";
    Some ( Tools.spy1_int entry_number )
  | None ->
    Messages.debug "No less launched cmd.";
    None
;;

(* Function to determinate what is the next command to
 * execute. It takes the current numbers from tmp file. *)
let what_next ~tmp =
  Tmp_file.get_accurate_log ~tmp ()
  (* Find the less launched, with order *)
  |> less_launched
;;

(* Display an error message if command can't run
 * if 0 status, do nothing
 * else display status number *)
let display_result command status =
  match status with
  | 0 -> (* No problem, do nothing *) ()
  | _ -> (* Problem occur, report it *)
    sprintf "Problem while running: '%s'\nExited with code: %i\n"
      command status
    |> Messages.warning
;;

(* Execute some command and log it *)
let execute ?(display=true) cmd =
  set_title cmd;

  Tmp_file.log ~cmd ~func:((+) 1) ();
  if display then
    Messages.ok cmd;
  (* We can remove lock file since number in tmp_file has been incremented *)
  Lock.remove ();
  Sys.command cmd
  |> display_result cmd (* Make it settable in rc file *)
;;
