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
  return (fun verbosity no_color rc_file_name handle_signal ->
         (* Set the level of verbosity *)
         Const.verbosity := verbosity;
         (* Do not use color *)
         Const.no_color := no_color || !Const.no_color;
         (* Use given rc file, should run the nth argument if present *)
         Const.rc_file := (Lazy.return rc_file_name);
         (* Active signal handling *)
         if handle_signal then
           Signals.handle ();

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
  (* Flag to handle signals *)
  <*> flag "-s" no_arg
        ~aliases:["--signals" ; "-signals"]
        ~doc:" Handle signals. Warning, this is not much tested and not \
              implemented the best way."
;;


(* basic-commands *)

(* To reset tmp file *)
let reset =
  basic
    ~summary:"Reinitialises launches for the command number [command] to [n]. \
              With both the [command] and the [n] argumennt, the command number \
              [command] is resetted to [n]. \
              With only the [n] argument, every entry in current tmp file is resetted to [n]."
    Spec.(
      empty
      +> shared_params
      +> anon ("target_number" %: int)
      +> anon (maybe ("command_number" %: int))
    )
    (fun { rc } num cmd () ->
       (* Call the right function, according to optionnal argument.
        * Since it's arguments passed on command line, we can not have
        * num = None
        * cmd = Some n
        * cmd: number of the command to be reseted
        * num: number to reset *)
       match ( num, cmd ) with
       | ( num, Some cmd ) -> Tmp_file.reset_cmd ~rc num cmd
       | ( num, None ) -> Tmp_file.reset2num ~rc num
    )
;;
let reset_all =
  basic
    ~summary:" Reinitialises launches for everything."
    Spec.(
      empty
      +> shared_params
    )
    (fun { rc } () ->
       Tmp_file.reset_all ()
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
       List_rc.run ~rc ())
;;

(* To clean-up rc file *)
let clean =
  basic
    ~summary:"Remove doubled entries, trailing spaces in them... \
              Useful after manual editing or with rc file from old version."
    Spec.(
      empty
      +> shared_params
    )
    (fun { rc } () ->
       Clean_command.run ~rc ()
    )
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
    (fun { rc } () ->
       State.print_current ~rc ())
;;


(* To edit the nth command *)
let edit =
  basic
    ~summary:"Edit the [COMMAND_NUMBER]th command of the rc file in your \
              $EDITOR. May be used to add new entries, without argument, one new \
              command per line."
    Spec.(
      empty
      +> shared_params
      +> anon (maybe ("command_number" %: int))
    )
    (fun { rc } n () ->
       let position = Option.value
                        ~default:(List.length (rc.Settings_t.progs) - 1) n
       in
       Edit_command.run ~rc position)
;;

(* To display informations about the licence *)
let licence =
  basic
    ~summary:"Display the licence of the program"
    Spec.(
      empty
      +> shared_params
      +> flag "-header" no_arg
           ~doc:" Display the header of the licence"
    )
    (fun _ header () ->
       (* When cecill is false, it displays the header *)
       let cecill = not(header) in
       Licencing.print ~cecill
    )
;;

(* Run nth command, default use *)
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
  (* Store begin time *)
  let start = Time.now () in


  (* XXX Hack to allow to run 'oclaunch 5' or 'oclaunch' as before, i.e. do not
   * display help for sub commands but use the program directly *)
  let hack_parse () =
    let run_default () =
      default
      |> run ~version ~build_info
    in
    match Sys.argv with
    | [| _ |] -> Result.Ok (run_default ()) (* Program called with nothing *)
    | _ -> (* Program followed by a number *)
      Or_error.try_with (fun () ->
             (* Verify the fist argument is a number, not a subcommand (string) *)
             ignore (Int.of_string (Sys.argv.(1)));
             run_default ())
  in

  (* Parsing with subcommands *)
  let parse_sub () =
    group
      ~summary:"OcLaunch program is published under CeCILL licence.\n \
                You may run the program with 'licence' command or see \
                http://cecill.info/licences/Licence_CeCILL_V2.1-en.html \
                (http://huit.re/TmdOFmQT) for details. More informations here: \
                http://oclaunch.eu.org/floss-under-cecill (http://lnch.ml/l)."
      ~readme:(fun () -> "Use 'help' subcommand to get help (it works both \
                          after the name of the software and with another subcommand). For \
                          further help, see http://oclaunch.eu.org.")
      ~preserve_subcommand_order:()
      [ ("run", default) ; ("licence", licence) ; ("add", add) ; ("edit", edit)
      ; ("list", list) ; ("cleanup", clean) ; ("delete", delete)
      ; ("state", state) ; ( "reset", reset) ; ( "reset-all", reset_all) ]
    |> run ~version ~build_info
  in

  (* Return error code with exceptions *)
  let exit_code =
    match
      hack_parse ()
      |> (function
             Result.Ok () -> ()
           | Error _ -> parse_sub ())
    with
    | () -> `Exit 0
    | exception message ->
      "Exception: " ^ (Exn.to_string message)
      |> Messages.warning;
      `Exit 20
  in

  (* Unlock, should be done before *)
  Lock.(status ()
        |> (function
               Locked ->
               Messages.warning "Removing lockfile, should be removed before. \
                                 It's a bug!"; remove ()
             | Free -> ()
             | Error -> Messages.warning "Error with lockfile"
           ));

  (* Display total running time, pretty printing is handled by Time module *)
  Messages.debug Time.(diff (now ()) start
                       |> Span.to_string_hum (* Round the value, 3 digits *)
                       |> sprintf "Duration: %s");

  (* Reset display *)
  Messages.reset ();

  exit_code
;;
