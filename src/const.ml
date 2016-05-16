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

(* File to store configuration variables *)

open Core.Std;;

(* We need to be as lazy as possible, since sometimes, some varible are not
 * needed and thus, it's useless the raise an exception. *)

(* General function to get environment variables
 * default: default value for the variable, if not set *)
let get_var: ?default:(string lazy_t) -> string lazy_t -> string lazy_t =
  fun ?default name ->
    let open Lazy in
    let msg =
      name >>| fun name ->
      sprintf "ERROR: Could not get $%s. Please consider setting it." name
    in
    (* Get the var *)
    name >>= fun name ->
    Sys.getenv name
    |> (function
         | Some x -> lazy x
         | None -> Option.value_exn ~message:(Lazy.force msg) default)
;;

(* Get current home *)
let home =
  get_var (lazy "HOME")
;;

(* Get default editor *)
let editor = (* If editor is not set, it gets "", but an exception is raised *)
  get_var (lazy "EDITOR")
;;

(* Level of verbosity, used by Messages module *)
let verbosity =
  ref (get_var ~default:(lazy "4") (lazy "OC_VERB")
       |> Lazy.force
       |> Int.of_string);;
(* Whether we ask for confirmation, used by Messages module *)
(* None -> ask, no preference defined,
 * Some true -> assume Yes
 * Some false -> assume No *)
let ask_unset = -1;; (* Constant to leave preference unset *)
let ask =
  ref (get_var ~default:(lazy (Int.to_string ask_unset)) (lazy "OC_YES")
       |> Lazy.force
       |> Int.of_string
       (* XXX Hacking with get_var, using
        * -1 for None, 0 for Some false and 1 for Some true *)
       |> function
         | unset when unset = ask_unset -> None | 0 -> Some false | 1 -> Some true
         | _ -> None
  )
;;
(* Use do not use colors, 0 -> false, anything -> true *)
let no_color =
  ref (get_var ~default:(lazy "0") (lazy "OC_NOCOLOR")
       |> Lazy.force
       |> (function "0" -> false | _ -> true)
      )
;;

(* Default place to read settings *)
let rc_file_default =
  let internal_default : string lazy_t =
    (* Default value, if no value is given (for instance as
       command line argument), or no environnement variable is set *)
    Lazy.(home >>| fun home -> home ^ "/" ^ ".oclaunch_rc.json")
  in
  get_var ~default:internal_default (lazy "OC_RC")
;;
(* Current place to read settings, maybe modified from command line argument *)
let rc_file = ref rc_file_default;;
(* Set tmp file, in witch stock launches, in biniou format *)
let tmp_file =
  get_var ~default:(lazy ("/tmp/.oclaunch_trace.dat")) (lazy "OC_TMP")
  |> Lazy.force
;;
(* Default max number for launch *)
let default_launch = 1;; (* TODO set it in rc file *)
