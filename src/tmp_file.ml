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
        Messages.ok "Reinitialises tmp file\n"; (* TODO Make it settable *)
        Sys.remove name;
        create_tmp_file ();
        read ()

(* Function to create the tmp file *)
and create_tmp_file () =
    Tmp_biniou_v.create_tmp_file ~command:[] ~number:0 ()
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
   ~func is the function applied to the value *)
let log ?(func= (+) 1 ) () =
  (* Make sure that file exists, otherwise strange things appears *)
  let file = init () in
  (* Write the file with the new value *)
  write { file with Tmp_biniou_t.number = (func file.Tmp_biniou_t.number)}
;;

(* Reset command number in two ways :
    * if cmd_num is 0, delete tmp file, to reinitialise program
    * if cmd_num is 0>, set to this value
    * else display an error message *)
let reset cmd_num =
    match cmd_num with
    | 0 -> (*Verify that file exist and if not, delete it *)
            Sys.file_exists Const.tmp_file
            |> (function
                | `No -> Messages.ok "Tmp file already removed"
                | `Unknown -> Messages.warning "Error while removing tmp file"
                | `Yes -> Sys.remove Const.tmp_file; Messages.ok "Tmp file removed"
            )
    | n when n > 0 ->
            (* Set the number *)
            log ~func:((fun a b -> a) n) ();
            sprintf "Tmp file reseted to %i" n |> Messages.ok
    | _ -> Messages.warning "Invalid number" (* TODO Make it settable *)
;;
