(* Auto-generated from "settings.atd" *)


type rc_file = Settings_t.rc_file = {
  progs: string list;
  settings: string list
}

val create_rc_file :
  progs: string list ->
  settings: string list ->
  unit -> rc_file
  (** Create a record of type {!rc_file}. *)

val validate_rc_file :
  Ag_util.Validation.path -> rc_file -> Ag_util.Validation.error option
  (** Validate a value of type {!rc_file}. *)

