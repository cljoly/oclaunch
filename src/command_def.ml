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

(* A set of default arguments, usable with most of the commands *)
let common =
  let open Spec in
  empty
    (* Flag to set verbosity level *)
    +> flag "-v" (optional_with_default !Const.verbosity int)
    ~aliases:["--verbose" ; "-verbose"]
    ~doc:"[n] Set verbosity level. \
        The higher n is, the most verbose the program is."
    (* Flag to set colors *)
    +> flag "--no-color" no_arg
        ~aliases:["-no-color"]
        ~doc:" Use this flag to disable color usage."
    (* Flag to use different rc file *)
    +> flag "-c" (optional_with_default (Lazy.force !Const.rc_file) file)
    ~aliases:["--rc" ; "-rc"]
    ~doc:"file Read configuration from the given file and continue parsing."
;;

(* Way to treat common args *)
let parse_common ~f = fun verbosity no_color rc_file_name ->
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
  (* A default number, corresponding to first item *)
  (*let default_n = (Option.value ~default:0 num_cmd) in*)
  f ~rc:rc_content (*~default*)
;;


(* Almost all the subcommands are defined the same way
 * f: function to parse the special arguments
 * summary: summary of the subcommand
 * args: the args of the subcommand
 * name: the name of the subcommand *)
let sub ~f ~summary ~args name =
  let def =
    basic ~summary Spec.(common +> args)
      (parse_common ~f)
  in
    ( name, def )
;;

(* Sub-commands *)

(* To reset tmp file *)
let reset =
  sub
    ~summary:"[n][command] Reinitialises launches of a given [command] to [n]. \
        If no [n] is given, the entry is deleted. With neither [command] nor [n], all entries are reseted."
    ~args:Spec.(
       anon ("number" %: int)
    )
    ~f:(fun ~rc reset_cmd () ->
      (*Tmp_file.reset ~rc reset_cmd 0)*)
      printf "Working\n")
    "reset-tmp"
    (*
    +> flag "-r" (optional int)
        ~aliases:["-reset-tmp" ; "--reset-tmp"]
        ~doc:
    (* Flag to list each commands with its number *)
    +> flag "-l" no_arg
    ~aliases:["-list" ; "--list"]
    ~doc:" Print a list of all commands with their number. Useful to launch with number. \
    Displays a star next to next command to launch."
    (* Flag to add a command to rc file, from stdin or directly *)
    +> flag "-a" no_arg
    ~aliases:["-add" ; "--add"]
    ~doc:"[n] Add the command given on stdin to the configuration file at a given position. If nothing is given, append it."
    (* Flag to remove a command from rc file *)
    +> flag "-d" no_arg
    ~aliases:["-delete" ; "--delete"]
    ~doc:"[n] remove the nth command from configuration file. If n is absent, remove last one."
    (* Flag to display current number *)
    +> flag "-n" no_arg
    ~aliases:["-number" ; "--number"]
    ~doc:" Display current state of the program."
    (* Flag to edit the nth command *)
    +> flag "-m" no_arg
    ~aliases:["-modify" ; "--modify" ; "--edit" ; "-edit"]
    ~doc:"[n] Edit the nth command of the rc file in your $EDITOR. May be used to add new entries."

    +> anon (maybe ("Command number" %: int)))
;;

(* Define commands *)
let commands =
  Command.basic
    ~summary:"OcLaunch program is published under CeCILL licence.\nSee \
    http://cecill.info/licences/Licence_CeCILL_V2.1-en.html (http://huit.re/TmdOFmQT) for details."
    ~readme:(fun () -> "See http://oclaunch.tuxfamily.org for help.")
    args

    (fun verbosity no_color rc_file_name reset_cmd list_commands add delete number modify num_cmd () ->
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
       (* Edit the nth command *)
       else if modify then Edit_command.run ~rc:rc_content default_n
       else
         begin
           (* Other things to test, especially flags with arguments *)
           (* Reset to a value *)
           reset_cmd |> (function
             | Some reset_cmd -> Tmp_file.reset ~rc:rc_content reset_cmd default_n
             | None -> ());

           (* Else: Run the nth command *)
           sprintf "Default: run nth command: %s"
             (match num_cmd with None -> "None"
                | Some n -> "Some " ^ (Int.to_string n)) |> Messages.debug;
           Default.run ~rc:rc_content num_cmd;
           Messages.debug "Default: end"
         end
        )
;;
*)

let run ~version ~build_info () =
  begin
    match
      group ~summary:"Most of the commands."
        [ reset ]
    |> run ~version ~build_info
    with
    | () -> exit 0
    | exception _ -> exit 20
  end;
  (* Reset display *)
  Messages.reset ()
;;
