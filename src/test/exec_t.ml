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

(* A module containing tests for src/exec_cmd.ml *)

(* Function less_launched *)
let less_launched test solution () =
  let actual = Exec_cmd.less_launched test in
  OUnit.assert_equal actual solution
;;

(* Function less_launched_num *)
let less_launched_num test solution () =
  let actual = Exec_cmd.less_launched_num test in
  OUnit.assert_equal actual solution
;;

(* Data for above test *)
let ll_data =
  let max = Const.default_launch in
  [
  ( [ ( "cmd1", 4 ) ; ( "cmd2", 0 ) ], Some "cmd2", "Canonical case 1" );
  ( [ ( "cmd1", 0 ) ; ( "cmd2", 5 ) ], Some "cmd1", "Canonical case 2" );
  ( [], None, "Empty list" );
  ( [ ( "cmd1", max ) ; ( "cmd2", (max + 5) ) ], None, "Everything (strcitly) superior to max" );
  ( [ ( "cmd1", 4 ) ; ( "cmd2", 4 ) ], None, "Twice the same number" );
]
;;
let ll_data2 =
  let max = Const.default_launch in
  [
  ( [ ( "cmd1", 0 ) ; ( "cmd2", 5 ) ], Some 0, "Canonical case 1" );
  ( [ ( "cmd1", 4 ) ; ( "cmd2", 0 ) ], Some 1, "Canonical case 2" );
  ( [ ( "cmd1", 0 ) ; ( "cmd2", 3 ) ; ( "cmd3", 4 )  ; ( "cmd4", 5 ) ], Some 0, "Canonical case 3" );
  ( [ ( "cmd1", 0 ) ; ( "cmd2", 4 ) ; ( "cmd3", 4 )  ; ( "cmd5", 5 ) ], Some 0,
  "Twice the same number, with others" );
  ( [], None, "Empty list" );
  ( [ ( "cmd1", max ) ; ( "cmd2", (max + 5) ) ], None, "Everything (strcitly) superior to max" );
  ( [ ( "cmd1", 4 ) ; ( "cmd2", 4 ) ], None, "Twice the same number" );
]
;;

let llt_l =
  let less_launched_suit =
    List.map ll_data ~f:(fun (t, s, name) -> ( (less_launched t s), name))
  in
  less_launched_suit
  |> List.map ~f:(fun ( f,name ) -> (name, `Quick, f))
;;

let llt_l2 =
  let less_launched_num_suit =
    List.map ll_data2 ~f:(fun (t, s, name) -> ( (less_launched_num t s), name))
  in
  less_launched_num_suit
  |> List.map ~f:(fun ( f,name ) -> (name, `Quick, f))
;;

(* To be used in test.ml *)
let alco = [( "Exec_cmd.ml.less_launched", llt_l ) ;
  ( "Exec_cmd.ml.less_launched_num", llt_l2 )];;


