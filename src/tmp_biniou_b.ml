(* Auto-generated from "tmp_biniou.atd" *)


type tmp_file = Tmp_biniou_t.tmp_file = { command: string list; number: int }

let _1_tag = Bi_io.array_tag
let write_untagged__1 = (
  Ag_ob_run.write_untagged_list
    Bi_io.string_tag
    (
      Bi_io.write_untagged_string
    )
)
let write__1 ob x =
  Bi_io.write_tag ob Bi_io.array_tag;
  write_untagged__1 ob x
let string_of__1 ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write__1 ob x;
  Bi_outbuf.contents ob
let get__1_reader = (
  Ag_ob_run.get_list_reader (
    Ag_ob_run.get_string_reader
  )
)
let read__1 = (
  Ag_ob_run.read_list (
    Ag_ob_run.get_string_reader
  )
)
let _1_of_string ?pos s =
  read__1 (Bi_inbuf.from_string ?pos s)
let tmp_file_tag = Bi_io.record_tag
let write_untagged_tmp_file : Bi_outbuf.t -> tmp_file -> unit = (
  fun ob x ->
    Bi_vint.write_uvint ob 2;
    Bi_outbuf.add_char4 ob '\129' 'm' 'q' 'K';
    (
      write__1
    ) ob x.command;
    Bi_outbuf.add_char4 ob '\161' 'z' '\134' '\201';
    (
      Bi_io.write_svint
    ) ob x.number;
)
let write_tmp_file ob x =
  Bi_io.write_tag ob Bi_io.record_tag;
  write_untagged_tmp_file ob x
let string_of_tmp_file ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write_tmp_file ob x;
  Bi_outbuf.contents ob
let get_tmp_file_reader = (
  fun tag ->
    if tag <> 21 then Ag_ob_run.read_error () else
      fun ib ->
        let field_command = ref (Obj.magic 0.0) in
        let field_number = ref (Obj.magic 0.0) in
        let bits0 = ref 0 in
        let len = Bi_vint.read_uvint ib in
        for i = 1 to len do
          match Bi_io.read_field_hashtag ib with
            | 23949643 ->
              field_command := (
                (
                  read__1
                ) ib
              );
              bits0 := !bits0 lor 0x1;
            | 561678025 ->
              field_number := (
                (
                  Ag_ob_run.read_int
                ) ib
              );
              bits0 := !bits0 lor 0x2;
            | _ -> Bi_io.skip ib
        done;
        if !bits0 <> 0x3 then Ag_ob_run.missing_fields [| !bits0 |] [| "command"; "number" |];
        (
          {
            command = !field_command;
            number = !field_number;
          }
         : tmp_file)
)
let read_tmp_file = (
  fun ib ->
    if Bi_io.read_tag ib <> 21 then Ag_ob_run.read_error_at ib;
    let field_command = ref (Obj.magic 0.0) in
    let field_number = ref (Obj.magic 0.0) in
    let bits0 = ref 0 in
    let len = Bi_vint.read_uvint ib in
    for i = 1 to len do
      match Bi_io.read_field_hashtag ib with
        | 23949643 ->
          field_command := (
            (
              read__1
            ) ib
          );
          bits0 := !bits0 lor 0x1;
        | 561678025 ->
          field_number := (
            (
              Ag_ob_run.read_int
            ) ib
          );
          bits0 := !bits0 lor 0x2;
        | _ -> Bi_io.skip ib
    done;
    if !bits0 <> 0x3 then Ag_ob_run.missing_fields [| !bits0 |] [| "command"; "number" |];
    (
      {
        command = !field_command;
        number = !field_number;
      }
     : tmp_file)
)
let tmp_file_of_string ?pos s =
  read_tmp_file (Bi_inbuf.from_string ?pos s)
