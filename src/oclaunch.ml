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

(* Variable to store version number *)
(* TODO Get value from file *)
let version_number = "0.2.0-dev";;

(* Variable store building information *)
(* XXX This is fake value, it corresponds to the running
 * information *)
let build_info = ( "Build with OCaml version " ^ (Sys.ocaml_version) ^ " on " ^ (Sys.os_type) );;

(* Obtain data from rc file *)
let rc_content = File_com.init_rc ();;

(* Define commands *)
let commands =
  Command.basic
    ~summary:"OcLaunch program is published under CeCILL licence. See
    https://gitlab.com/WzukW/oclaunch for details."
    ~readme:(fun () -> "See https://gitlab.com/WzukW/oclaunch for help.")
    (* TODO if number is out of the mist, return error message *)
    Command.Spec.(empty
    (* Flag to reset tmp file *)
    +> flag "-r" no_arg
        ~aliases:["-reset-tmp" ; "--reset-tmp"]
        ~doc:"Reinitialises launches by setting a new number in temporal file.
        If nothing is given, reinitialises to 0 and delete tmp file."
    (* Flag to list each commands with its number *)
    +> flag "-l" no_arg
    ~aliases:["-list" ; "--list"]
    ~doc:"Print a list of all command with its number. Useful to launch with number"
    (* Flag to add a command to rc file, from stdin or directly *)
    +> flag "-a" no_arg
    ~aliases:["-add" ; "--add"]
    ~doc:"Add the command given on stdin to configuration file at a given position. If nothing is given, append it."
    +> anon (maybe ("Command number" %: int)))
    (fun reset_tmp list_commands add num_cmd () ->
       (* First try to list or add *)
       if list_commands then List_rc.run ~rc:rc_content
       else if add then Add_command.run ~rc:rc_content num_cmd
       else
       match reset_tmp with
         | true -> (* Reset temp file, if nothing is given, put 0 value *)
                 Tmp_file.reset (Option.value ~default:0 num_cmd)
         | false -> Default.run ~rc:rc_content num_cmd
    )
;;

let () =
  Command.run ~version:version_number ~build_info:build_info commands
;;
