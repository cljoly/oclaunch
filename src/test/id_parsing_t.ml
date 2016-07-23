(******************************************************************************)
(* Copyright © Joly Clément, 2015                                             *)
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

(* A module containing tests for src/id_parsing.ml *)

(* Function to_human ============================= *)
let to_human test solution () =
  let actual = Id_parsing.list_from_human test in
  OUnit.assert_equal actual solution
;;

(* Data for above test *)
let ll_data = [
  ( "1", [1], "Canonical case: unique" );
  ( "1-3", [1;2;3], "Canonical case: between" );
  ( "3-1", [3;2;1], "Canonical case: between, reversed" );
  ( "1-3,5-8,10-12", [1;2;3;5;6;7;8;10;11;12], "Canonical case: list of interval" );
  ( "1,3,5", [1;3;5], "Canonical case: list of unique" );
  ( "1-3,5,10-12,23", [1;2;3;5;10;11;12;23], "Canonical case: both" );
  ( "0-30", [0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18;
  19; 20; 21; 22; 23; 24; 25; 26; 27; 28; 29; 30], "Long interval" );
  ( "1-3", [1;2;3], "With errors" );
  ( "1-3", [1;2;3], "With double" );
  ( "", [], "Empty list" );
  ( "aaaavvvbg", [], "Empty list resulting of incorrect input" );
]

let llt_l =
  List.map ll_data ~f:(fun (t, s, name) -> ( (to_human t s), name))
  |> List.map ~f:(fun ( f,name ) -> (name, `Quick, f))
;;
(* =========================================== *)

(* To be used in test.ml *)
let alco = [( "Id_parsing.ml: to human", llt_l )];;

