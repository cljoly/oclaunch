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

(* A module containing tests for src/edit_command.ml *)

(* Function epur ============================= *)
let epur test solution () =
  let actual = Edit_command.epur test in
  OUnit.assert_equal actual solution
;;

(* Data for above test *)
let ll_data = [
  ( [ "cmd1" ; "cmd2"; "" ], [ "cmd1" ; "cmd2" ], "Canonical case" );
  ( [ "" ; "cmd1" ; "" ; "" ; "cmd2"; "" ], [ "cmd1" ; "cmd2" ], "Harder case" );
  ( [], [], "Empty list" );
  ( [ "" ; "" ; "" ], [], "Empty list resulting of empty strings" );
]

let llt_l =
  List.map ll_data ~f:(fun (t, s, name) -> ( (epur t s), name))
  |> List.map ~f:(fun ( f,name ) -> (name, `Quick, f))
;;
(* =========================================== *)


(* Function new_list ========================= *)
let n_list ( current_list, position, new_items ) solution () =
  let actual = Edit_command.new_list current_list position new_items in
  OUnit.assert_equal actual solution
;;

(* Data for above test *)
let nl_data = [
  ( ( [ "cmd1" ; "cmd2" ; "cmd3" ], 1, ["new_cmd"] ), [ "cmd1" ; "new_cmd" ; "cmd2" ; "cmd3" ], "Canonical case 1" );
  ( ( [ "cmd1" ; "cmd2" ; "cmd3" ; "cmd4" ; "cmd5" ], 2, [ "cmd"  ; "cmd" ; "cmd" ] ),
      [ "cmd1" ; "cmd2" ; "cmd"  ; "cmd" ; "cmd" ; "cmd3" ; "cmd4" ; "cmd5" ],
      "Canonical case 2" );
  ( ( [ "cmd1" ; "cmd2" ; "cmd3" ], 0, ["new_cmd"] ), [ "new_cmd" ; "cmd1" ;
  "cmd2" ; "cmd3" ], "Insert on top" );
  ( ( [ "cmd1" ; "cmd2" ; "cmd3" ; "cmd4" ; "cmd5" ], 4, ["new_cmd"] ), [ "cmd1"
  ; "cmd2" ; "cmd3" ; "cmd4" ; "new_cmd" ; "cmd5" ], "Insert bottom" );
  ( ( [], 0, [] ), [], "Empty list" );
  ( ( [], 0, [ "new" ; "element" ] ), [ "new" ; "element" ], "Insertion of new elements in an empty list" );
  ( ( [], 5, [ "new" ; "element" ] ), [ "new" ; "element" ], "Out of bound (inserting elements)" );
  ( ( [], 5, [] ), [], "Out of bound (inserting nothing)" );
]

let big =
  (
    "Big list",
    `Slow,
    (fun () ->
      let l = List.init 1_000_000 ~f:(fun a -> a) in
      let pos = 5 in
      let actual = Edit_command.new_list l pos [ -2 ; -1 ] in
      let conformity li =
        ((List.nth_exn li pos) = -2) &&
        ((List.nth_exn li (succ pos)) = -1)
      in
      OUnit.assert_bool "My test" (conformity actual)
    )
  )
;;

let lt_l =
  List.map nl_data ~f:(fun (t, s, name) -> ( (n_list t s), name))
  |> List.map ~f:(fun ( f,name ) -> (name, `Quick, f))
;;
(* =========================================== *)

(* To be used in test.ml *)
let alco = [( "Edit_command.ml: Epur", llt_l ) ;
  ( "Edit_command.ml: New list", ( big :: lt_l ) )
];;



