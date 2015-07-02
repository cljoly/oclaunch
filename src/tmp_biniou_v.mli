(* Auto-generated from "tmp_biniou.atd" *)


type rc_entry = Tmp_biniou_t.rc_entry = { commands: (string * int) }

type tmp_file = Tmp_biniou_t.tmp_file = { rc: rc_entry list; daemon: int }

val create_rc_entry :
  commands: (string * int) ->
  unit -> rc_entry
  (** Create a record of type {!rc_entry}. *)

val validate_rc_entry :
  Ag_util.Validation.path -> rc_entry -> Ag_util.Validation.error option
  (** Validate a value of type {!rc_entry}. *)

val create_tmp_file :
  rc: rc_entry list ->
  daemon: int ->
  unit -> tmp_file
  (** Create a record of type {!tmp_file}. *)

val validate_tmp_file :
  Ag_util.Validation.path -> tmp_file -> Ag_util.Validation.error option
  (** Validate a value of type {!tmp_file}. *)

