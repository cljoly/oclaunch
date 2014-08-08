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

(* Function to return the corresponding command to a number *)
let num_cmd_to_cmd ~cmd_list number =
  (*Verify that the number is not out of the list *)
  if (List.length cmd_list) < number
  then
    ""
  else
    begin
      let cmd_to_exec = List.nth cmd_list number in
        match cmd_to_exec with
            | None -> ""
            | Some x -> x
    end
;;

(* Function to determinate what is the next command to
 * execute *)
let what_next ~tmp ~cmd_list =
  let tmp_json = Yojson.Basic.from_file tmp in
  let open Yojson.Basic.Util in
  let num_next = tmp_json |> member "num" |> to_int in (* Number of the next cmd to run *)
    num_cmd_to_cmd ~cmd_list:cmd_list num_next
  ;;

(* Log when a program has been launched in a file in /tmp
   ~func is the function applied to the value *)
let log ?(func= (+) 1 ) ~file_name =
  let file = Yojson.Basic.from_file file_name in
  match file with
    | `Assoc [( a, `List b ); ("num", `Int c)] -> let new_value = `Assoc [( a, `List b ); ("num", `Int (c |> func))] in Yojson.Basic.to_file file_name new_value
    | _ -> failwith "Incorrect format"
;;

(* Execute some command and log it *)
let execute ?(display=true) ~tmp cmd =
    log ~func:((+) 1) ~file_name:tmp;
    if display then
        print_endline cmd;
    Sys.command cmd;
;;
