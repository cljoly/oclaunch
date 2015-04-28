(* Auto-generated from "tmp_biniou.atd" *)


type tmp_file = Tmp_biniou_t.tmp_file = { command: string list; number: int }

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

