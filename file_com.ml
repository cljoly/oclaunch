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

(* Get string from file *)
let string_f_file file =
	let tmp_buffer = In_channel.create file in
	let content = In_channel.input_all tmp_buffer in
	(* Now, close file and return value *)
	In_channel.close tmp_buffer; content
;;

(* Function to read the tmp file *)
let init_tmp ~tmp:tmp_file =
	string_f_file tmp_file
	|> Tmp_log_j.tmp_trace_of_string
;;

(* Function to read the rc file *)
let init_rc ~rc:rc_file =
	string_f_file rc_file
	|> Settings_j.rc_file_of_string
;;

(* Verify that the value exist *)
let verify_key_exist ~key entry =
	if entry = key then
		true
	else
		false
;;
(* Stock a value a file in /tmp
   ~target is the target file *)
let stock_tmp ~key ~value ~target =
  let num_value = List.find target ~f:(verify_key_exist ~key:key) in
    num_value
;;
