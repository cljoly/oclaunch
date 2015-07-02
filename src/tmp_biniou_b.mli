(* Auto-generated from "tmp_biniou.atd" *)


type rc_entry = Tmp_biniou_t.rc_entry = { commands: (string * int) }

type tmp_file = Tmp_biniou_t.tmp_file = { rc: rc_entry list; daemon: int }

(* Writers for type rc_entry *)

val rc_entry_tag : Bi_io.node_tag
  (** Tag used by the writers for type {!rc_entry}.
      Readers may support more than just this tag. *)

val write_untagged_rc_entry :
  Bi_outbuf.t -> rc_entry -> unit
  (** Output an untagged biniou value of type {!rc_entry}. *)

val write_rc_entry :
  Bi_outbuf.t -> rc_entry -> unit
  (** Output a biniou value of type {!rc_entry}. *)

val string_of_rc_entry :
  ?len:int -> rc_entry -> string
  (** Serialize a value of type {!rc_entry} into
      a biniou string. *)

(* Readers for type rc_entry *)

val get_rc_entry_reader :
  Bi_io.node_tag -> (Bi_inbuf.t -> rc_entry)
  (** Return a function that reads an untagged
      biniou value of type {!rc_entry}. *)

val read_rc_entry :
  Bi_inbuf.t -> rc_entry
  (** Input a tagged biniou value of type {!rc_entry}. *)

val rc_entry_of_string :
  ?pos:int -> string -> rc_entry
  (** Deserialize a biniou value of type {!rc_entry}.
      @param pos specifies the position where
                 reading starts. Default: 0. *)

(* Writers for type tmp_file *)

val tmp_file_tag : Bi_io.node_tag
  (** Tag used by the writers for type {!tmp_file}.
      Readers may support more than just this tag. *)

val write_untagged_tmp_file :
  Bi_outbuf.t -> tmp_file -> unit
  (** Output an untagged biniou value of type {!tmp_file}. *)

val write_tmp_file :
  Bi_outbuf.t -> tmp_file -> unit
  (** Output a biniou value of type {!tmp_file}. *)

val string_of_tmp_file :
  ?len:int -> tmp_file -> string
  (** Serialize a value of type {!tmp_file} into
      a biniou string. *)

(* Readers for type tmp_file *)

val get_tmp_file_reader :
  Bi_io.node_tag -> (Bi_inbuf.t -> tmp_file)
  (** Return a function that reads an untagged
      biniou value of type {!tmp_file}. *)

val read_tmp_file :
  Bi_inbuf.t -> tmp_file
  (** Input a tagged biniou value of type {!tmp_file}. *)

val tmp_file_of_string :
  ?pos:int -> string -> tmp_file
  (** Deserialize a biniou value of type {!tmp_file}.
      @param pos specifies the position where
                 reading starts. Default: 0. *)

