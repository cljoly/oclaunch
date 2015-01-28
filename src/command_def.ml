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

(* Module containing the definition of the interface of OcLaunch *)

(* Arguments *)
let args =
    let open Command.Spec in
    (empty
    (* Flag to use different rc file *)
    +> flag "-c" (optional_with_default !Const.rc_file file)
    ~aliases:["--rc" ; "-rc"]
    ~doc:"file Read configuration from the given file and continue parsing."
    (* Flag to reset tmp file *)
    +> flag "-r" no_arg
        ~aliases:["-reset-tmp" ; "--reset-tmp"]
        ~doc:"[n] Reinitialises launches by setting a new number in temporal file.
        If nothing is given, reinitialises to 0 and delete tmp file."
    (* Flag to list each commands with its number *)
    +> flag "-l" no_arg
    ~aliases:["-list" ; "--list"]
    ~doc:" Print a list of all commands with their number. Useful to launch with number. Displays a star next to next command to launch."
    (* Flag to add a command to rc file, from stdin or directly *)
    +> flag "-a" no_arg
    ~aliases:["-add" ; "--add"]
    ~doc:"[n] Add the command given on stdin to the configuration file at a given position. If nothing is given, append it."
    (* Flag to remove a command from rc file *)
    +> flag "-d" no_arg
    ~aliases:["-delete" ; "--delete"]
    ~doc:"[n] remove the nth command from configuration file. If n is absent, remove last one"
    (* Flag to display current number *)
    +> flag "-n" no_arg
    ~aliases:["-number" ; "--number"]
    ~doc:" Display current state of the program"
    (* Flag to edit the nth command *)
    +> flag "-m" no_arg
    ~aliases:["-modify" ; "--modify"]
    ~doc:"[n] Edit the nth command of the rc file."

    +> anon (maybe ("Command number" %: int)))
;;

(* Define commands *)
let commands =
  Command.basic
    ~summary:"OcLaunch program is published under CeCILL licence. See
    https://gitlab.com/WzukW/oclaunch for details."
    ~readme:(fun () -> "See https://gitlab.com/WzukW/oclaunch for help.")
    args

    (fun rc_file_name reset_tmp list_commands add delete number modify num_cmd () ->
       (* Use given rc file, should run the nth argument if present *)
       Const.rc_file := rc_file_name;
       (* Obtain data from rc_file *)
       let rc_content = File_com.init_rc () in
       (* A default number, corresponding to first item *)
       let default_n = (Option.value ~default:0 num_cmd) in
       (* First try to list *)
       if list_commands then List_rc.run ~rc:rc_content
       (* To add command to rc file *)
       else if add then Add_command.run ~rc:rc_content num_cmd
       (* To delete command from rc file *)
       else if delete then Remove_command.run ~rc:rc_content num_cmd
       (* To print current state *)
       else if number then State.print_current ()
       (* Reset to a value *)
       else if reset_tmp then Tmp_file.reset default_n
       (* Edit the nth command *)
       else if modify then Edit_command.run ~rc:rc_content default_n
       (* Else: Run the nth command *)
       else Default.run ~rc:rc_content num_cmd
    )
;;
