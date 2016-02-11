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

(* A module containing tests for src/unitfy.ml *)

(* Function make_uniq ============================= *)
let make_uniq test solution () =
  let actual = Unify.make_uniq test in
    OUnit.assert_equal actual solution
;;

(* Big and sometimes strange list, to be used in test data set.
   Returning tuple like this (test_case, expected, message) list.
   Test case is the list to be tested, expected is the deduplicated one and
   message is a string to displayed when testing this case *)
let big_unique length = (* Long list of unique elements *)
  let message = "unique element" in
  let test_case = List.init ~f:(fun i -> Int.to_string i) length in
    ( test_case, test_case, message )
;;
let big_same length = (* Long list of unique elements *)
  let message = "all the same element" in
  let same_element = "cmd1" in
  let test_case = List.init ~f:(fun i -> same_element) length in
    ( test_case, [ same_element ], message )
;;
let big_periodic length = (* Long list of unique elements *)
  let message = "periodically the same element" in
  let periode = 9 in
  (* Element inserted on the periode *)
  let dbl = length + 42 |> Int.to_string in
  let sol = ref [] in
  let test_case = List.init ~f:(fun i ->
     if i mod periode = 0
     then dbl
     else Int.to_string i
          (* Keep for the solution *)
          |> (fun t -> sol := t :: !sol; t)) length
  in
    ( test_case, dbl :: !sol, message )
;;
let big_long_entry length = (* Long list of unique elements *)
  let message = "long unique element" in
  let test_case = List.init ~f:(fun i -> "Longer entries, numbered thouth. This one is number \
                                          is: " ^ (Int.to_string i)) length in
    ( test_case, test_case, message )
;;
(* Function packing the preceding *)
let big_pack ~message length =
  (* List of function to be packed *)
  [
    big_unique ;
    big_same ;
    big_periodic ;
    big_long_entry
  ] |>
  List.map ~f:(fun f -> f length)
  (* Returning tuple like this (test_case, expected, message) list *)
  |> List.map ~f:(fun (t, s, msg) -> (t, s, message ^ msg))
;;
(* Data set for above test *)
let make_uniq_data = [
  ( [ "cmd1" ; "cmd2"; "" ; "cmd1" ], [ "cmd1" ; "cmd2"; ""], "Canonical case" );
  (* Make sure no reordering is appening *)
  ( [ "cmd33" ; "cmd2" ; "" ; "" ; "cmd1"; "" ], [ "cmd33" ; "cmd2" ; "" ; "cmd1" ],
    "Test order" );
  ( [ "cmd1" ; "" ; "cmd2" ], [ "cmd1" ; "" ; "cmd2" ],
    "No duplicate" );
  ( [], [], "Empty list" );
]
  (* Speed is an important aspect, test it. *)
  @ (big_pack ~message:"Quite small list of " 10)
  @ (big_pack ~message:"Practically max length list of " 100)
;;

let t_set_fast =
  List.map make_uniq_data ~f:(fun (t, s, name) -> ( (make_uniq t s), name))
  |> List.map ~f:(fun ( f,name ) -> (name, `Quick, f))
;;

let t_set_long =
  List.map
    ((big_pack ~message:"Much longer than real use case list of " 1_000)
     @ (big_pack ~message:"Crazy long list of " 9_999))
    ~f:(fun (t, s, name) -> ( (make_uniq t s), name))
  |> List.map ~f:(fun ( f,name ) -> (name, `Slow, f))
;;

let t_set = t_set_fast @ t_set_long;;
(* =========================================== *)

(* To be used in test.ml *)
let alco = [( "Unify.ml.Make_uniq", t_set )];;

