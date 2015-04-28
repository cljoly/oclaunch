(* Auto-generated from "settings.atd" *)


type rc_file = Settings_t.rc_file = {
  progs: string list;
  settings: string list
}

val write_rc_file :
  Bi_outbuf.t -> rc_file -> unit
  (** Output a JSON value of type {!rc_file}. *)

val string_of_rc_file :
  ?len:int -> rc_file -> string
  (** Serialize a value of type {!rc_file}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_rc_file :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> rc_file
  (** Input JSON data of type {!rc_file}. *)

val rc_file_of_string :
  string -> rc_file
  (** Deserialize JSON data of type {!rc_file}. *)

