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

(* Type of the values *)
type t = Tmp_biniou_t.tmp_file;;

(* Function to write the tmp file *)
let write (tmp_file:t) =
    (* Short name *)
    let name = Const.tmp_file in
    let biniou_tmp = Tmp_biniou_b.string_of_tmp_file tmp_file in
    Out_channel.write_all name ~data:biniou_tmp
;;

(* XXX Using and keyword because each function can call each other *)
(* Function to read the tmp file *)
let rec read () =
    (* Short name *)
    let name = Const.tmp_file in
    (* Get the string corresponding to the file *)
    let file_content = In_channel.read_all name in
    try
        Tmp_biniou_b.tmp_file_of_string file_content
    (* In previous version, the JSON format was used, otherwise the file can
     * have a bad format. In this case, the Ag_ob_run.Error("Read error (1)")
     * exeption is throw. We catch it here *)
    with _ ->
        (* If file is not in the right format, delete it and create a new one.
         * Then, read it *)
        Messages.ok "Reinitialises tmp file\n";
        Sys.remove name;
        create_tmp_file ();
        read ()

(* Function to create the tmp file *)
and create_tmp_file () =
    (* An empty list, without rc, commands, launch... *)
    Tmp_biniou_v.create_tmp_file ~daemon:0 ~rc:[] ()
    (* Convert it to biniou *)
    |> write
;;

(* Function to open tmp file *)
let rec init () =
  (* If file do not exists, create it *)
  let file_exists = Sys.file_exists Const.tmp_file in
    match file_exists with
      | `No -> create_tmp_file ();
          init ()
      | `Unknown -> begin
          Sys.remove Const.tmp_file;
          init ()
        end
      | `Yes -> read ()
;;

(* Get a log of values from the tmp file, like this
 * (cmd,number of launch) list *)
let get_log ~rc_tmp =
  List.map ~f:(fun { Tmp_biniou_t.commands = (cmd,number) } ->
        (cmd,number)) rc_tmp
;;

(* Verify that the value exist *)
let verify_key_exist ~key entry =
    if entry = key then
        true
    else
        false
;;

(* Return true if a program is in the rc file *)
let rec is_prog_in_rc list_from_rc_file program =
    match list_from_rc_file with
    (* | None -> is_prog_in_rc program ~liste_from_rc_file:rc_content.progs *)
    | [] -> false
    | hd :: tl -> if hd = program then true else is_prog_in_rc tl program
;;

(* Log when a program has been launched in a file in /tmp
   ~func is the function applied to the value
   ~cmd is the launched entry *)
let log ~cmd ?(func= (+) 1 ) () =
  (* Make sure that file exists, otherwise strange things appears *)
  let file = init () in
  (* Get rc_file name *)
  let name = Lazy.force !Const.rc_file in
  (* Function to generate the new list with right number *)
  let new_li (li : Tmp_biniou_t.rc_entry list) =
    let open List.Assoc in
    (* Only number of launch associated with commands *)
    let l = get_log ~rc_tmp:li in
    find l cmd
      |> (function None -> add l cmd Const.default_launch | Some n -> add l cmd (func n))
      |> List.map ~f:(fun e -> { Tmp_biniou_t.commands = e})
    in
  (* Write the file with the new value *)
  let updated_li =
    List.Assoc.(find file.Tmp_biniou_t.rc name)
      |> Option.value ~default:[]
      |> new_li
  in
  write Tmp_biniou_t.{ file with rc = List.Assoc.add file.rc name
  updated_li }
;;

(* Return current number *)
let get_current () =
    failwith "Deprecated"
;;

(* Get number of launch for each command in rc file, as follow:
  * (command:string, number of the command:int) list *)
let get_accurate_log ?rc_name ~tmp () =
  let open List in

  (* Read rc *)
  (* XXX Forcing evaluation of lazy value Const.rc_file before it is
   *   necessary *)
  let name : string = Option.value ~default:(Lazy.force !Const.rc_file) rc_name
  in
  let rc =  File_com.init_rc ~rc:(Lazy.return name) () in

  let rc_in_tmp = get_log ~rc_tmp:(Assoc.find tmp.Tmp_biniou_t.rc name
    |> Option.value ~default:[])
  in
  map rc.Settings_t.progs ~f:(fun key ->
        Assoc.find rc_in_tmp key
    |> Option.value ~default:0
    |> (function number -> (key,number)))
;;

(* Reset number of launch for a given command
 * cmd: number of the command to be reseted
 * num: number to reset *)
let reset_cmd ~rc num cmd =
  (* Debugging *)
  [(num,"num") ; (cmd,"cmd")]
    |> List.map ~f:(fun (i , str) -> str ^ ": " ^ (Int.to_string i))
    |> List.iter ~f:(fun s -> Messages.debug s);

  let ac_log = get_accurate_log ~tmp:(init ()) () in
  (* The command (string) corresponding to the number *)
  let cmd_str =
    File_com.num_cmd2cmd ~rc cmd
    |> function
      Some s -> s
      | None -> failwith "Out of bound"
  in

  (* Current number of launch for that cmd *)
  let i = List.Assoc.find_exn ac_log cmd_str in
    sprintf  "Last N for command '%s' was %i"
      cmd_str
      i
    |> Messages.info;
    sprintf  "Restore with 'oclaunch reset %i %i'" i cmd
    |> Messages.tips;

    (* Do the work, set the number *)
    log ~func:(fun _ -> num) ~cmd:cmd_str ();
    sprintf "Reseted command '%s' to %i successfully" cmd_str num |> Messages.ok
;;

(* Reset all commands to a number
 * num: number to reset *)
let reset2num ~rc num =
  (* Debugging *)
  "Num: " ^ (Int.to_string num)
  |> Messages.debug;

  let ac_log = get_accurate_log ~tmp:(init ()) () in

  (* Erase number of launch for each command *)
  List.iter ac_log ~f:(fun ( cmd, _ ) ->
    log ~func:(fun _ -> num) ~cmd ())
;;

(* Reset all command *)
let reset_all () =
  Messages.debug "Preparing to reset all";
  let reset_without_ask () =
    (* Make sure that file exists, otherwise strange things appears *)
    let tmp = init () in
    (* Get rc_file name *)
    let name = Lazy.force !Const.rc_file in
    write Tmp_biniou_t.{ tmp with rc = List.Assoc.add tmp.rc name [] }
  in
  Messages.debug "Asking question";
  Messages.confirm "You will lose number of launch for every command.\
    Are you sure?"
  |> (fun answer -> sprintf "Answer %s" (Messages.answer2str answer) |> Messages.debug; answer) (* Spy *)
    |> function
      Messages.Yes -> reset_without_ask ()
      | Messages.No -> ()
;;

