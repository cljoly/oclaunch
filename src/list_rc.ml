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

(* This modules contains function to list the content of the rc file *)


(* Characters to append to show a command was truncated *)
let trunc_indicator = "...";;

(* Truncate to elength, and add [trunc_indicator] after entries longer than
 * elength or let them going through unmodified. *)
(* Special case when elength < length(trunc_indicator), nothing is done *)
let truncate ?elength str =
  let trunc_ind_l = String.length trunc_indicator in
  let elength =
    (* TODO Set 80 in Const *)
    Option.value ~default:80 elength
  in

  (* Cache it, to debug and for the condition later *)
  let str_length = String.length str in
  sprintf "Length of the command: %i" str_length |> Messages.debug;
  sprintf "Elength: %i" elength |> Messages.debug;

  (* We test separately, before truncating, that:
   * - elength is not <= to the length of the indicator, otherwise the command
   * should pass untouched
   * - the command is longer than elength *)
  if not(elength <= trunc_ind_l) && str_length > elength
  (* String.prefix is inclusive but incompatible with
   * 0 to keep whole string. Truncate to elength - trunc_ind_l since we add the
   * trunc_indicator (we need to cut a bit more) *)
  then String.prefix str (elength - trunc_ind_l) |> fun short_entry ->
       String.concat [ short_entry ; trunc_indicator ]
  else str
;;

(* Generate list to feed the table, returning list of tuples
 * (number of a command in rc file, command, number of launch). *)
(* XXX assuming all will be in the right order (from id 0 to 10) *)
(* FIXME Remove ?rc or use it *)
let generate_list ?rc ?elength log =
  let rc_numbered =
    File_com.init_rc ()
    |> fun rc -> rc.Settings_t.progs
                 |> List.mapi ~f:(fun i item -> ( item, i ))
  in
  List.map log ~f:(function ( cmd, number ) ->
    [
      (List.Assoc.find_exn rc_numbered cmd |> Int.to_string);
      (* Limit length, to get better display with long command. A default
       * length is involved when no length is specified *)
      truncate ?elength cmd;
      (Int.to_string number)
    ])
;;

(* Function which list, rc would be automatically reread, this optional
 * argument is kept for backward compatibility
 * elength: truncate entries to length (0 does nothing)*)
(* TODO:
 * - Test it, esp. ordering
 * - Allow to set form of the table, multiple rc file, display next to be
 * launched… *)
let run ?rc ?elength () =
  let tmp : Tmp_file.t = Tmp_file.init () in
  Tmp_file.get_accurate_log ~tmp ()
  |> generate_list ?rc ?elength
  |> Textutils.Ascii_table.simple_list_table
       ~display:Textutils.Ascii_table.Display.column_titles
       [ "Id" ; "Command" ; "Number of launch" ]
;;

