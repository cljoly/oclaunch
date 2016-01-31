(******************************************************************************)
(* Copyright © Joly Clément, 2015                                             *)
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

(* Various tools for the program *)

(* Printing methods, common to all function in this modules *)
let printing = Messages.debug;;

(* Spying expression, template for the others. Takes the string corespondig to
 * the original value and return the original one *)
let spy orig (value : string) =
  printing value;
  orig
;;

(* Functions exposed to spy special types *)
let spy1_int i =
  sprintf "%i" i
  |> spy i
;;
let spy1_int_option io =
  let i = io |> (function
    None -> "None"
    | Some i -> sprintf "Some %i" i)
  in
  spy io i
;;
let spy1_string str =
  spy str str
;;
let spy1_float f =
  sprintf "%f" f
  |> spy f
;;
let spy1_list ~f list =
  let list_str = List.map list ~f:(fun element ->
    sprintf "\"%s\"; " (f element))
  in
  "[ " ^ (String.concat list_str) ^ " ]"
  |> printing;
  list
;;
let spy1_log (log : (string * int) list) =
  let log_str = List.map log ~f:(fun (s, i) ->
    sprintf "( \"%s\", %i ); " s i)
  in
  "[ " ^ (String.concat log_str) ^ " ]"
  |> printing;
  log
;;
let spy1_rc rc =
  failwith "Not implemented"
;;
