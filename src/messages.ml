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

(* Modules to manage output messages, with color *)

(* TODO
    * allow to set verbosity
    * allow to toggle colors
    * allow to display bold & underlined messages *)

(* Types corresponding to some colors & style of the Core_extended.Color_print
 * library *)
type color =
    | Green
    | Red
    | Yellow
    | White
    | Plum
;;

type style =
    | Bold
    | Underline
    | Normal
;;

(* General function to print things *)
let print ~color ~style message =
    let open Core_extended in
    (* This code create proper escapement to display text with bold/color... *)
    color |>
    (function
        | Green -> Color_print.color ~color:`Green message
        | Red -> Color_print.color ~color:`Red message
        | Yellow -> Color_print.color ~color:`Yellow message
        | White -> Color_print.color ~color:`White message
        | Plum -> Color_print.color ~color:`Plum message
    ) |> (* Finaly print escaped string *)
    (fun colored_msg ->
        match style with
        | Bold -> Color_print.boldprintf "%s" colored_msg
        | Underline -> Color_print.underlineprintf "%s" colored_msg
        | Normal -> printf "%s" colored_msg
    )
;;

(* Print debugging, information, important... messages *)
let debug message =
    let mess = (Time.now()|> Time.to_string) ^ " " ^ message ^ "\n" in
    print ~color:Plum ~style:Underline mess
;;

let info message =
    let mess = message ^ "\n" in
    print ~color:White ~style:Normal mess
;;

let warning message =
    let mess = message ^ "\n" in
    print ~color:Red ~style:Bold mess
;;

let ok message =
    let mess = message ^ "\n" in
    print ~color:Green ~style:Bold mess
;;

let tips message =
    let mess = message ^ "\n" in
    print ~color:Yellow ~style:Normal mess
;;
