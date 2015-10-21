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

open Core.Std;;

(* Module to mange locking, when another instance of OcLaunch is running *)

(* Status of the locker *)
type lock_status =
    Locked
  | Free
  | Error
;;
(* Name of the lock file *)
(* TODO Put it in Const *)
let lock_name = "/tmp/.ocl.lock";;

(* Create lock file *)
let lock () =
    try Out_channel.write_all lock_name ~data:"OcLaunch is running and did not finish."
    with Sys_error msg -> Messages.debug "Couldn't write in lock file."
;;

(* To know if we are locked, return None if there is no locker,  *)
let status () =
    match Sys.file_exists lock_name with
      `Yes -> Locked
    | `No -> Free
    | `Unknown -> Error
;;

(* Remove the lock file *)
let remove () =
    Sys.remove lock_name
;;

(* Pause the program until lock file is removed, until argument is the second *)
(* We hide loop argument from outside, since it's used internally, to
 * count number of passages and make until argument useful *)
let wait ?(until=10) ?(delay=1) () =
  let rec wait_loop loop =
    (* Actually wait, returning what has been done (Something or Nothing) *)
    sprintf "Waiting for locker, loop: %i" loop
      |> Messages.debug;
    match status () with
      Locked ->
        if loop < until; then (* < because we start from 0 *)
          begin
            Unix.sleep delay;
            wait_loop (succ loop)
          end
        else
          None
    | Free -> Some (lock ())
    | Error -> failwith "Problem with lock file"
  in
  wait_loop 0
    |> (function
       None ->
         Messages.warning "Removing lock file, ran out of patience";
         remove ();
         (* We need to lock back, since it's the purpose of this function *)
         lock ()
       | _ -> ()
    )
;;

