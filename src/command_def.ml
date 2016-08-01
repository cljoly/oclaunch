(******************************************************************************)
(* Copyright © Joly Clément, 2014-2015                                        *)
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

open Core.Std;;

open Command;;

(* Module containing the definition of the interface of OcLaunch *)

(* Type to return result of the work with common arguments *)
type return_arg = {
  rc : Settings_t.rc_file Lazy.t;
}

(* Shorthand *)
let id_seq = Id_parsing.id_sequence;;
let iter_seq = Id_parsing.helper;;

(* A set of default arguments, usable with most of the commands *)
let shared_params =
  let open Param in
  (* Way to treat common args *)
  return (fun verbosity assume_yes no_color rc_file_name handle_signal ->
         (* Set the level of verbosity *)
         Const.verbosity := verbosity;
         (* Ask question or not, see Const.ask for details *)
         Const.ask := Option.(
                merge
                  (some_if assume_yes true)
                  !Const.ask
                  ~f:( || )
              );
         (* Do not use color *)
         Const.no_color := no_color || !Const.no_color;
         (* Use given rc file, preserving lazyness, since Const.rc_file is not
          * yet evaluated *)
         Const.rc_file :=
           Option.value_map ~f:(fun rfn -> Lazy.return rfn)
             ~default:!Const.rc_file rc_file_name
         ;
         (* Active signal handling *)
         if handle_signal then
           Signals.handle ();

         (* Debugging *)
         let d = Messages.debug in
         d (sprintf "Verbosity set to %i" !Const.verbosity);
         d (match !Const.ask with
             | None -> "Assume nothing"
             | Some false -> "Assume No"
             | Some true -> "Assume Yes");
         d (sprintf "Color %s" (match !Const.no_color with true -> "off" | false -> "on"));
         begin
           match Option.try_with (fun () -> Lazy.force !Const.rc_file) with
           | None -> d "Configuration file will fail if used";
           | Some rc -> d (sprintf "Configuration file is %s" rc);
         end;
         d (sprintf "Tmp file is %s" Const.tmp_file);

         (* Obtain data from rc_file *)
         d "Reading rc_file...";
         let rc_content = lazy (File_com.init_rc ()) in
         d "Read rc_file";
         { rc = rc_content } (* We use type for futur use *)
       )
  (* Flag to set verbosity level *)
  <*> flag "-v" (optional_with_default !Const.verbosity int)
        ~aliases:["--verbose" ; "-verbose"]
        ~doc:"[n] Set verbosity level. \
              The higher n is, the most verbose the program is."
  (* Flag to assume yes *)
  <*> flag "-y" no_arg
        ~aliases:["--yes" ; "-yes"]
        ~doc:" Assume yes, never ask anything. \
              Setting OC_YES environment variable to '1' is the same. \
              Set it to '0' to assume no. \
              Set it to '-1' to be asked every time."
  (* Flag to set colors *)
  <*> flag "--no-color" no_arg
        ~aliases:["-no-color"]
        ~doc:" Use this flag to disable color usage."
  (* Flag to use different rc file *)
  <*> flag "-c" (optional file)
        ~aliases:["--rc" ; "-rc"]
        ~doc:"file Read configuration from the given file and continue parsing."
  (* Flag to handle signals *)
  <*> flag "-s" no_arg
        ~aliases:["--signals" ; "-signals"]
        ~doc:" Handle signals. Warning, this is not much tested and not \
              implemented the best way."
;;

(* Comman documentation for id sequences *)
let id_parsing_doc =
  ". Id sequence means a set of ids like this: 1,4-9,17. The command is run \
   for each item of the generated list (1,4,5,6,7,8,9,17 in this case)"

(* basic-commands *)

(* To reset tmp file *)
let reset =
  basic
    ~summary:("Reinitialises launches for the command number [command] to [n]. \
               With both the [command] and the [n] argumennt, the command number \
               [command] is resetted to [n]. \
               With only the [n] argument, every entry in current tmp file is \
               resetted to [n]. [command] may be a sequence of ids"
              ^ id_parsing_doc)
    Spec.(
      empty
      +> shared_params
      +> anon ("target_number" %: int)
      +> anon (maybe ("command_number" %: id_seq))
    )
    (fun { rc } num cmd () ->
       (* Call the right function, according to optionnal argument.
        * Since it's arguments passed on command line, we can not have
        * num = None
        * cmd = Some n
        * cmd: number of the command to be reseted
        * num: number to reset *)
       let rc = Lazy.force rc in
       match ( num, cmd ) with
       | ( num, None ) | ( num, Some [] ) -> Tmp_file.reset2num ~rc num
       | ( num, Some cmd_list ) ->
         List.iter ~f:(fun cmd -> Tmp_file.reset_cmd ~rc num cmd) cmd_list
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
      +> flag "-l" (optional int)
           ~aliases:[ "--length" ; "-length" ; "--elength" ; "-elength" ]
           ~doc:" Max length of displayed entries, 0 keeps as-is"
    )
    (fun { rc } elength () ->
       let rc = Lazy.force rc in
       List_rc.run ~rc ?elength ())
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
       let rc = Lazy.force rc in
       Clean_command.run ~rc ()
    )
;;

(* To add a command to rc file, from stdin or directly *)
let add =
  basic
    ~summary:("Add the command given on stdin to the configuration file at a \
               given position(s) ([id_sequence]). If nothing is given, or if \
               it is out of bound, append commands at the end"
              ^ id_parsing_doc)
    Spec.(
      empty
      +> shared_params
      +> anon (maybe ("id_sequence" %: id_seq))
    )
    (fun { rc } cmd_seq () ->
       let rc = Lazy.force rc in
       iter_seq ~f:(fun num_cmd -> Add_command.run ~rc num_cmd) cmd_seq
    )
;;

(* To remove a command from rc file *)
let delete =
  basic
    ~summary:("Remove the [COMMAND_NUMBER]th command from configuration file. \
               If [COMMAND_NUMBER] is absent, remove last one. \n\
               [COMMAND_NUMBER] may be a sequence of ids"
              ^ id_parsing_doc)
    Spec.(
      empty
      +> shared_params
      +> anon (maybe ("command_number" %: id_seq))
    )
    (fun { rc } cmd_seq () ->
       let rc = Lazy.force rc in
       iter_seq
         ~f:(fun num_cmd ->
              Remove_command.run ~rc num_cmd) cmd_seq)
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
       let rc = Lazy.force rc in
       State.print_current ~rc ())
;;


(* To edit the nth command *)
let edit =
  basic
    ~summary:("Edit the [COMMAND_NUMBER]th command of the rc file in your \
               $EDITOR. May be used to add new entries, without argument, one new \
               command per line. \n\
               [COMMAND_NUMBER] may be a sequence of ids"
              ^ id_parsing_doc)

    Spec.(
      empty
      +> shared_params
      +> anon (maybe ("command_number" %: id_seq))
    )
    (fun { rc } cmd_seq () ->
       let rc = Lazy.force rc in
       iter_seq cmd_seq ~f:(fun n ->
              let position =
                Option.value n
                  ~default:(List.length (rc.Settings_t.progs) - 1)
              in
              Edit_command.run ~rc position)
    )
;;

(* To display informations about the licence *)
let licence =
  basic
    ~summary:"Display the licence of the program"
    Spec.(
      empty
      +> shared_params
      +> flag "-header" no_arg
           ~doc:" Display the header associated to the licence"
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
    ~summary:("Run the id sequence" ^ id_parsing_doc)
    Spec.(
      empty
      +> shared_params
      +> anon (maybe ("command_number" %: id_seq))
    )
    (fun { rc } cmd_seq () ->
       let rc = Lazy.force rc in
       iter_seq cmd_seq ~f:(fun n -> Default.run ~rc n)
    )

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
      ~summary:"OcLaunch program is published under CeCILL licence.\n\
                You may run the program with 'licence' command or see \
                http://cecill.info/licences/Licence_CeCILL_V2.1-en.html \
                (https://lnch.ml/cecill) for details. More here: \
                https://oclaunch.eu.org/floss-under-cecill (https://lnch.ml/l)."
      ~readme:(fun () -> File_com.welcome_msg)
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
    (* XXX Command.basic function catch exceptions, so this doesn't actually
     * work. We may to place it before basic function to fix the problem. *)
    | exception message ->
      "Exception: " ^ (Exn.to_string message)
      |> Messages.warning;
      Bug.report ();
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
