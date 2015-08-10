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

open Command;;

(* Module containing the definition of the interface of OcLaunch *)

(* Type to return result of the work with common arguments *)
type return_arg = {
  rc : Settings_t.rc_file;
}

(* A set of default arguments, usable with most of the commands *)
let shared_params =
  let open Param in
  (* Way to treat common args *)
  return (fun verbosity no_color rc_file_name ->
    (* Set the level of verbosity *)
    Const.verbosity := verbosity;
    (* Do not use color *)
    Const.no_color := no_color;
    (* Use given rc file, should run the nth argument if present *)
    Const.rc_file := (Lazy.return rc_file_name);

    (* Debugging *)
    Messages.debug (sprintf "Verbosity set to %i" !Const.verbosity);
    Messages.debug (sprintf "Color %s" (match !Const.no_color with true -> "off" | false -> "on"));
    Messages.debug (sprintf "Configuration file is %s" (Lazy.force !Const.rc_file));
    Messages.debug (sprintf "Tmp file is %s" Const.tmp_file);

    (* Obtain data from rc_file *)
    let rc_content = File_com.init_rc () in
    { rc = rc_content } (* We use type for futur use *)
  )
  (* Flag to set verbosity level *)
    <*> flag "-v" (optional_with_default !Const.verbosity int)
      ~aliases:["--verbose" ; "-verbose"]
      ~doc:"[n] Set verbosity level. \
        The higher n is, the most verbose the program is."
    (* Flag to set colors *)
    <*> flag "--no-color" no_arg
        ~aliases:["-no-color"]
        ~doc:" Use this flag to disable color usage."
    (* Flag to use different rc file *)
    <*> flag "-c" (optional_with_default (Lazy.force !Const.rc_file) file)
      ~aliases:["--rc" ; "-rc"]
      ~doc:"file Read configuration from the given file and continue parsing."
;;


(* basic-commands *)

(* To reset tmp file *)
let reset =
  basic
    ~summary:"OUTDATED\n Reinitialises launches of a given [command] to [n]. \
      If no [n] is given, the entry is deleted. \
      With neither [command] nor [n], all entries are reseted."
    Spec.(
      empty
       +> shared_params
       +> anon ("command_number" %: int)
       +> anon ("target_number" %: int)
    )
    (fun { rc } reset_cmd default_n () ->
      Tmp_file.reset ~rc reset_cmd default_n
    )
;;

(* To list each commands with its number *)
let list =
  basic
    ~summary:"Print a list of all commands with their number. Useful to launch with number. \
    Displays a star next to next command to launch."
    Spec.(
      empty
      +> shared_params
    )
    (fun { rc } () ->
      List_rc.run ~rc)
;;

(* To add a command to rc file, from stdin or directly *)
let add =
  basic
    ~summary:"Add the command given on stdin to the configuration file at a \
    given position ([NUMBER]). If nothing is given, append it."
    Spec.(
      empty
      +> shared_params
      +> anon  (maybe ("number" %: int))
    )
    (fun { rc } num_cmd () ->
      Add_command.run ~rc num_cmd
    )
;;

(* To remove a command from rc file *)
let delete =
  basic
    ~summary:"Remove the [COMMAND_NUMBER]th command from configuration file. \
    If [COMMAND_NUMBER] is absent, remove last one."
    Spec.(
      empty
       +> shared_params
       +> anon (maybe ("command_number" %: int))
    )
    (fun { rc } num_cmd () ->
      (*Tmp_file.reset ~rc reset_cmd 0)*)
      Remove_command.run ~rc num_cmd)
;;

(* To display current state *)
let state =
  basic
    ~summary:"Display current state of the program."
    Spec.(
      empty
      +> shared_params
    )
    (fun _ () ->
      State.print_current ())
;;


(* To edit the nth command *)
let edit =
  basic
    ~summary:"Edit the [COMMAND_NUMBER]th command of the rc file in your \
    $EDITOR. May be used to add new entries."
    Spec.(
      empty
      +> shared_params
      +> anon ("command_number" %: int)
    )
    (fun { rc } default_n () ->
      Edit_command.run ~rc default_n)
;;

(* Run th enth command, default use *)
let default =
  basic
    ~summary:"Run the [COMMAND_NUMBER]th command"
    Spec.(
      empty
      +> shared_params
      +> anon (maybe ("command_number" %: int))
    )
    (fun { rc } n () ->
      Default.run ~rc n)

let run ~version ~build_info () =
  let exit_code =
    match
    group
      ~summary:"OcLaunch program is published under CeCILL licence.\nSee \
      http://cecill.info/licences/Licence_CeCILL_V2.1-en.html (http://huit.re/TmdOFmQT) for details."
      ~readme:(fun () -> "See http://oclaunch.tuxfamily.org for help.")
      [ ( "reset-tmp", reset) ; ("list", list) ; ("add", add) ; ("delete",
      delete) ; ("state", state) ; ("edit", edit) ; ("run", default) ]
    |> run ~version ~build_info
    with
    | () -> `Exit 0
    | exception message ->
        "Exception: " ^ (Exn.to_string message)
        |> Messages.warning;
        `Exit 20
  in
  (* Reset display *)
  Messages.reset ();

  exit_code
;;
