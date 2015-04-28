(* Auto-generated from "tmp_biniou.atd" *)


type tmp_file = Tmp_biniou_t.tmp_file = { command: string list; number: int }

val create_tmp_file :
  command: string list ->
  number: int ->
  unit -> tmp_file
  (** Create a record of type {!tmp_file}. *)

val validate_tmp_file :
  Ag_util.Validation.path -> tmp_file -> Ag_util.Validation.error option
  (** Validate a value of type {!tmp_file}. *)

