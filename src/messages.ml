(******************************************************************************)
(* Copyright © Joly Clément, 2014-2015-2016                                   *)
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

(* Modules to manage output messages, with color *)

(* TODO
 * - allow to display bold & underlined messages *)

(* Store whether a message was already displayed to reset if necessary (see
 * function reset) *)
let already = ref false

(* Function to keep a trace of colored messages *)
let log_already () =
  match !already with
  | false -> already := true
  | true -> ()
;;

(* Types corresponding to some colors & style of the Core_extended.Color_print
 * library *)
type color =
  | Green
  | Red
  | Yellow
  | White
  | Plum
  | Cyan
;;

type style =
  | Bold
  | Underline
  | Normal
;;

(* General function to print things *)
let print ~color ~style message =
  (* Alias *)
  let cpcolor = Color_print.color in
  match !Const.no_color with
  | true -> printf "%s" message
  | false -> begin (* Use colors *)
      (* Log that we used colored messages *)
      log_already ();
      (* This code create proper escapement to display text with bold/color... *)
      color |>
      (function
        | Green -> cpcolor ~color:`Green message
        | Red -> cpcolor ~color:`Red message
        | Yellow -> cpcolor ~color:`Yellow message
        | White -> cpcolor ~color:`White message
        | Plum -> cpcolor ~color:`Plum message
        | Cyan -> cpcolor ~color:`Cyan message
      ) |> (* Finaly print escaped string *)
      (fun colored_msg ->
         let open Color_print in
         match style with
         | Bold -> bold_printf "%s" colored_msg
         | Underline -> underline_printf "%s" colored_msg
         | Normal -> printf "%s" colored_msg
      )
    end
;;

(* Behave in a conform way to verbosity
 * The higher is the number, the more important the message is, the lower
 * verbosity value display it *)
(* f: function to show the message
 * debug: fonction to call before f, for instance a debugging function displaying
 * date and time *)
let check_verbosity ?debug ~f function_number =
  (* Debugging function *)
  debug |> (function None -> () | Some debug_fonction -> debug_fonction ":");

  match function_number <= !Const.verbosity with
    true -> (* Display the message *)
    f ()
  | false -> ()
;;


(* Print debugging, information, important... messages *)
let debug message =
  check_verbosity ~f:(fun () ->
         let mess = (Time.now() |> Time.to_string) ^ " " ^ message ^ "\n" in
         print ~color:Plum ~style:Underline mess
       ) 5
;;

let info message =
  check_verbosity ~debug ~f:(fun () ->
         let mess = message ^ "\n" in
         print ~color:White ~style:Bold mess
       ) 3
;;

let warning message =
  check_verbosity ~debug ~f:(fun () ->
         let mess = message ^ "\n" in
         print ~color:Red ~style:Bold mess
       ) 1
;;

(* Type for the answers *)
type answer = Yes | No;;
(* Usefull to display result *)
let answer2str = function
    Yes -> "Yes" | No -> "No"
;;
(* State of the program, if you should always answer yes, no or ask to the user
 * (default)*)
(* TODO Put it in Const *)
let assume_yes = None;;
(* Allow to assume yes or no like with a --yes option *)
let check_assume_yes ~f =
  match assume_yes with
  | Some true -> Yes (* --yes *)
  | Some false -> No (* --no *)
  | None -> f ()
;;

(* Get confirmation
 * TODO:
 * allow option like -y
 * test it (display, line return, etc...) *)
let rec confirm info =
  check_assume_yes ~f:(fun () ->
         print ~color:Cyan ~style:Normal info;
         print ~color:Cyan ~style:Normal "\n(Yes/No): ";
         (* XXX Be sure to show the message *)
         Out_channel.(flush stdout);
         let str_answer = In_channel.(input_line ~fix_win_eol:true stdin) in
         str_answer |> Option.map ~f:String.lowercase
         |> (function
              | Some "y" | Some "ye" | Some "yes" -> Yes
              | Some "n" | Some "no" -> No
              | Some _ | None ->
                warning "Please enter 'yes' or 'no', or 'y' or 'n' (case \
                doesn't matter).";
                confirm info)
       )
;;

let ok message =
  check_verbosity ~debug ~f:(fun () ->
         let mess = message ^ "\n" in
         print ~color:Green ~style:Bold mess
       ) 2
;;

let tips message =
  check_verbosity ~debug ~f:(fun () ->
         let mess = message ^ "\n" in
         print ~color:Yellow ~style:Normal mess
       ) 4
;;


(* Reset printing, to avoid color problem on some terminal (Konsole), the  *)
let reset () =
  let open Color_print in
  match !already with
  | true -> debug "Reseted colors";
    normal "" |> printf "%s\n"
  | false -> debug "Not resetted"; ()
;;
