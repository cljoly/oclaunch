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

(* Read settings and programs to launch from rc file *)

(* Type of the values *)
type t = Settings_v.rc_file;;

(* Message to display on first use, i.e. on initialisation of rc file *)
let welcome_msg =
  sprintf
  "Nice to meet you! Here is some tips to get started with OcLaunch.\n\
   Use 'help' subcommand to get help (it works both after the name of the \
   software and with another subcommand). For instance run\n\
   `oclaunch help add`\n\
   For further help, see https://oclaunch.eu.org. Report any bug at %s\
   \n\
   \n\
   Feedback is welcome at feedback@oclaunch.eu.org.\n\
   To get remind for new stable versions, subscribe to our low-traffic mailing \
   list: announce@oclaunch.eu.org. \
   More here: https://lnch.ml/ml\n\
   See you soon! To keep in touch: https://lnch.ml/kt\n"
   Bug.url
;;

(* Function to write the rc file *)
let write (rc_file:t) =
  (* Short name *)
  let name = !Const.rc_file in
  (* Create string to be written, after removing duplicated commands (and
   * newlines) *)
  let data = (Unify.prettify rc_file |> Settings_j.string_of_rc_file
              |> Yojson.Basic.prettify ~std:true) in
  Out_channel.write_all (Lazy.force name) ~data
;;

(* Return the configuration file template *)
let rc_template () =
  Settings_v.create_rc_file ~progs:[] ~settings:[]
;;

(* Function to create configuration file if it does not
 * exist *)
let create_rc_file ~name =
  (* Notify that we initialise config file *)
  sprintf "Initializing empty configuration file in %s." name |> Messages.warning;
  (* Final \n to display newline before showing the licence. *)
  Messages.tips welcome_msg;
  (* Display licence information *)
  Licencing.print ~cecill:false;

  let compact_rc_file = Settings_j.string_of_rc_file (rc_template () ()) in
  let readable_rc_file = Yojson.Basic.prettify compact_rc_file in (* Create human readable string for rc file *)
  let out_file = Out_channel.create name in
  Out_channel.output_string out_file readable_rc_file;
  Out_channel.close out_file
;;

(* Function to read the rc file *)
let rec init_rc ?(rc=(!Const.rc_file)) () =
  let rc' = Lazy.force rc in
  (* Verify that file exist *)
  match (Sys.file_exists rc') with
  | `No -> create_rc_file ~name:rc'; init_rc ~rc ();
  | `Unknown -> failwith "Error reading configuration file";
  | `Yes -> (* Try to read, if there is an error, reset file *)
    try
      In_channel.read_all rc' |> Settings_j.rc_file_of_string
    with
    | Yojson.Json_error _ -> (* Invalid file, delete, so that it will be reseted
                                on next call *) Sys.remove rc'; init_rc ~rc ()
;;

(* Get the command corresponding to a number *)
let num_cmd2cmd ~rc n =
  List.nth rc.Settings_t.progs n
;;

