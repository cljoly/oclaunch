(******************************************************************************)
(* Copyright © Joly Clément, 2015                                        *)
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

open Core.Std
(*open Core_bench.Std*)

(* File to test who is the faster to swap two elements *)
(* TODO:
  * Use core_bench for trustable result
  * Improve list algo ?
  * Verify that output of all functions are the same *)

(* Arguments:
  * li: a list of elements
  * a,b: positions
  * a < b*)

let data =  List.init 5 ~f:(fun i -> i)
let big_data = List.init 1_000_000 ~f:(fun i -> i)

(* With an array *)
let array li a b =
  let ar = List.to_array li in
  (* Store a value *)
  let v = ar.(a) in
  ar.(a) <- ar.(a);
  ar.(b) <- v;
  Array.to_list ar
;;

(* Manipulating list *)
let list li a b =
  (* We need a < b *)
  let ( a, b ) : ( int * int ) =
    if a < b
    then ( a, b )
    else ( b, a )
  in
  let b' = List.nth_exn li b in (* Ephemeral value, to swap *)
  let a' = ref b' in (* Avoid walk around the list twice *)
  List.mapi li
    ~f:(fun i element ->
      if i = a
      then begin
        a' := element;
        b'
      end
      else if i = b
      then !a'
      else
        element
      )

let tests = [
  "Array - small list", (fun () -> array data 2 4);
  "Array - big list", (fun () -> array big_data 20 80);
  "List - small list", (fun () -> list data 2 4);
  "List - big list", (fun () -> list big_data 20 80);
]

(*let () =*)
  (*List.map tests ~f:(fun (name,test) -> Bench.Test.create ~name test)*)
  (*|> Bench.make_command*)
  (*|> Command.run*)

(* Manual way to test, it don't have core_bench yet *)
let man_run f =
  let open Time in
  let start = now () in
  let i = f () in
  let stop = now () in
  diff stop start |> Core.Span.to_string
;;

let () =
  List.map tests ~f:(fun (name,test) -> ( name, man_run test ))
  |> List.iter ~f:(fun ( name, duration ) -> printf "%s: %s\n" name duration)

