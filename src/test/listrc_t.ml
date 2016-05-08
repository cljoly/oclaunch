(******************************************************************************)
(* Copyright © Joly Clément, 2016                                             *)
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

(* A module containing tests for src/edit_command.ml *)

(* Function truncate *)
let trunc (str, elength, expected) () =
  let current = List_rc.truncate ~elength str in
  OUnit.assert_equal current expected
;;

let data = [
  ( ("", 4, ""), "Empty string" );

  ( ("cmd1", 4, "cmd1"), "Right length" );
  ( ("cmd11", 4, "c..."), "A bit longer" );
  ( ("cmdddd1", 4, "c..."), "Much too long" );

  ( ("cmd", 3, "cmd"), "Short command" );
  ( ("cm", 3, "cm"), "Shorter command" );
  ( ("c", 3, "c"), "Tiny command" );

  ( ("cmd1", 0, "cmd1"), "Keep as-is" );
  ( ("cmd1", -5, "cmd1"), "Negative figure, keep as-is" );
  ( ("cmd1", (String.length List_rc.trunc_indicator), "cmd1"),
    "On the indicator, keep as-is" );
  ( ("cmd1", (String.length List_rc.trunc_indicator) - 1, "cmd1"),
    "Under indicator, keep as-is" );
];;

let tests =
  List.map data ~f:(fun (t, name) ->
         (name, `Quick, (trunc t)))
;;

(* To be used in test.ml *)
let alco = [( "List_rc.ml", tests );];;

