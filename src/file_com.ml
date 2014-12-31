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

(* Read settings and programs to launch from rc file *)

(* Type of the values *)
type t = Settings_v.rc_file;;

(* Function to write the rc file *)
let write (tmp_file:t) =
        (* Short name *)
        let name = Const.rc_file in
        (* Create string to be written *)
        let data = (Settings_j.string_of_rc_file tmp_file
        |> Yojson.Basic.prettify ~std:true) in
        Out_channel.write_all name ~data
;;

(* Return the configuration file template *)
let rc_template () =
  Settings_v.create_rc_file ~progs:[] ~settings:[]
;;

(* Function to create configuration file if it does not
 * exist *)
let create_rc_file ~name =
  (* Notify that we initialise config file *)
  printf "Initializing configuration file in %s\n" name;
  let compact_rc_file = Settings_j.string_of_rc_file (rc_template () ()) in
  let readable_rc_file = Yojson.Basic.prettify compact_rc_file in (* Create human readable string for rc file *)
  let out_file = Out_channel.create name in
    Out_channel.output_string out_file readable_rc_file;
    Out_channel.close out_file
;;

(* Function to read the rc file *)
let rec init_rc ?(rc=Const.rc_file) () =
  (* Verify that file exist *)
  match (Sys.file_exists rc) with
    | `No -> create_rc_file ~name:rc; init_rc ~rc ();
    | `Unknown -> failwith "Error reading configuration file";
    | `Yes -> In_channel.read_all rc |> Settings_j.rc_file_of_string
;;
