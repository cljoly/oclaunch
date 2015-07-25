(* Auto-generated from "tmp_biniou.atd" *)


type rc_name = Tmp_biniou_t.rc_name

type rc_entry = Tmp_biniou_t.rc_entry = { commands: (string * int) }

type tmp_file = Tmp_biniou_t.tmp_file = {
  rc: (rc_name * (rc_entry list)) list;
  daemon: int
}

let rc_name_tag = Bi_io.string_tag
let write_untagged_rc_name = (
  Bi_io.write_untagged_string
)
let write_rc_name ob x =
  Bi_io.write_tag ob Bi_io.string_tag;
  write_untagged_rc_name ob x
let string_of_rc_name ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write_rc_name ob x;
  Bi_outbuf.contents ob
let get_rc_name_reader = (
  Ag_ob_run.get_string_reader
)
let read_rc_name = (
  Ag_ob_run.read_string
)
let rc_name_of_string ?pos s =
  read_rc_name (Bi_inbuf.from_string ?pos s)
let rc_entry_tag = Bi_io.record_tag
let write_untagged_rc_entry : Bi_outbuf.t -> rc_entry -> unit = (
  fun ob x ->
    Bi_vint.write_uvint ob 1;
    Bi_outbuf.add_char4 ob '\190' 'U' '\176' '\200';
    (
      fun ob x ->
        Bi_io.write_tag ob Bi_io.tuple_tag;
        Bi_vint.write_uvint ob 2;
        (
          let x, _ = x in (
            Bi_io.write_string
          ) ob x
        );
        (
          let _, x = x in (
            Bi_io.write_svint
          ) ob x
        );
    ) ob x.commands;
)
let write_rc_entry ob x =
  Bi_io.write_tag ob Bi_io.record_tag;
  write_untagged_rc_entry ob x
let string_of_rc_entry ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write_rc_entry ob x;
  Bi_outbuf.contents ob
let get_rc_entry_reader = (
  fun tag ->
    if tag <> 21 then Ag_ob_run.read_error () else
      fun ib ->
        let field_commands = ref (Obj.magic 0.0) in
        let bits0 = ref 0 in
        let len = Bi_vint.read_uvint ib in
        for i = 1 to len do
          match Bi_io.read_field_hashtag ib with
            | 1045803208 ->
              field_commands := (
                (
                  fun ib ->
                    if Bi_io.read_tag ib <> 20 then Ag_ob_run.read_error_at ib;
                    let len = Bi_vint.read_uvint ib in
                    if len < 2 then Ag_ob_run.missing_tuple_fields len [ 0; 1 ];
                    let x0 =
                      (
                        Ag_ob_run.read_string
                      ) ib
                    in
                    let x1 =
                      (
                        Ag_ob_run.read_int
                      ) ib
                    in
                    for i = 2 to len - 1 do Bi_io.skip ib done;
                    (x0, x1)
                ) ib
              );
              bits0 := !bits0 lor 0x1;
            | _ -> Bi_io.skip ib
        done;
        if !bits0 <> 0x1 then Ag_ob_run.missing_fields [| !bits0 |] [| "commands" |];
        (
          {
            commands = !field_commands;
          }
         : rc_entry)
)
let read_rc_entry = (
  fun ib ->
    if Bi_io.read_tag ib <> 21 then Ag_ob_run.read_error_at ib;
    let field_commands = ref (Obj.magic 0.0) in
    let bits0 = ref 0 in
    let len = Bi_vint.read_uvint ib in
    for i = 1 to len do
      match Bi_io.read_field_hashtag ib with
        | 1045803208 ->
          field_commands := (
            (
              fun ib ->
                if Bi_io.read_tag ib <> 20 then Ag_ob_run.read_error_at ib;
                let len = Bi_vint.read_uvint ib in
                if len < 2 then Ag_ob_run.missing_tuple_fields len [ 0; 1 ];
                let x0 =
                  (
                    Ag_ob_run.read_string
                  ) ib
                in
                let x1 =
                  (
                    Ag_ob_run.read_int
                  ) ib
                in
                for i = 2 to len - 1 do Bi_io.skip ib done;
                (x0, x1)
            ) ib
          );
          bits0 := !bits0 lor 0x1;
        | _ -> Bi_io.skip ib
    done;
    if !bits0 <> 0x1 then Ag_ob_run.missing_fields [| !bits0 |] [| "commands" |];
    (
      {
        commands = !field_commands;
      }
     : rc_entry)
)
let rc_entry_of_string ?pos s =
  read_rc_entry (Bi_inbuf.from_string ?pos s)
let _1_tag = Bi_io.array_tag
let write_untagged__1 = (
  Ag_ob_run.write_untagged_list
    rc_entry_tag
    (
      write_untagged_rc_entry
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
    get_rc_entry_reader
  )
)
let read__1 = (
  Ag_ob_run.read_list (
    get_rc_entry_reader
  )
)
let _1_of_string ?pos s =
  read__1 (Bi_inbuf.from_string ?pos s)
let _2_tag = Bi_io.array_tag
let write_untagged__2 = (
  Ag_ob_run.write_untagged_list
    Bi_io.tuple_tag
    (
      fun ob x ->
        Bi_vint.write_uvint ob 2;
        (
          let x, _ = x in (
            write_rc_name
          ) ob x
        );
        (
          let _, x = x in (
            fun ob x ->
              Bi_io.write_tag ob Bi_io.tuple_tag;
              Bi_vint.write_uvint ob 1;
              (
                let x = x in (
                  write__1
                ) ob x
              );
          ) ob x
        );
    )
)
let write__2 ob x =
  Bi_io.write_tag ob Bi_io.array_tag;
  write_untagged__2 ob x
let string_of__2 ?(len = 1024) x =
  let ob = Bi_outbuf.create len in
  write__2 ob x;
  Bi_outbuf.contents ob
let get__2_reader = (
  Ag_ob_run.get_list_reader (
    fun tag ->
      if tag <> 20 then Ag_ob_run.read_error () else
        fun ib ->
          let len = Bi_vint.read_uvint ib in
          if len < 2 then Ag_ob_run.missing_tuple_fields len [ 0; 1 ];
          let x0 =
            (
              read_rc_name
            ) ib
          in
          let x1 =
            (
              fun ib ->
                if Bi_io.read_tag ib <> 20 then Ag_ob_run.read_error_at ib;
                let len = Bi_vint.read_uvint ib in
                if len < 1 then Ag_ob_run.missing_tuple_fields len [ 0 ];
                let x0 =
                  (
                    read__1
                  ) ib
                in
                for i = 1 to len - 1 do Bi_io.skip ib done;
                (x0)
            ) ib
          in
          for i = 2 to len - 1 do Bi_io.skip ib done;
          (x0, x1)
  )
)
let read__2 = (
  Ag_ob_run.read_list (
    fun tag ->
      if tag <> 20 then Ag_ob_run.read_error () else
        fun ib ->
          let len = Bi_vint.read_uvint ib in
          if len < 2 then Ag_ob_run.missing_tuple_fields len [ 0; 1 ];
          let x0 =
            (
              read_rc_name
            ) ib
          in
          let x1 =
            (
              fun ib ->
                if Bi_io.read_tag ib <> 20 then Ag_ob_run.read_error_at ib;
                let len = Bi_vint.read_uvint ib in
                if len < 1 then Ag_ob_run.missing_tuple_fields len [ 0 ];
                let x0 =
                  (
                    read__1
                  ) ib
                in
                for i = 1 to len - 1 do Bi_io.skip ib done;
                (x0)
            ) ib
          in
          for i = 2 to len - 1 do Bi_io.skip ib done;
          (x0, x1)
  )
)
let _2_of_string ?pos s =
  read__2 (Bi_inbuf.from_string ?pos s)
let tmp_file_tag = Bi_io.record_tag
let write_untagged_tmp_file : Bi_outbuf.t -> tmp_file -> unit = (
  fun ob x ->
    Bi_vint.write_uvint ob 2;
    Bi_outbuf.add_char4 ob '\128' '\000' 'c' '\177';
    (
      write__2
    ) ob x.rc;
    Bi_outbuf.add_char4 ob '\152' '\163' '\253' '\132';
    (
      Bi_io.write_svint
    ) ob x.daemon;
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
        let field_rc = ref (Obj.magic 0.0) in
        let field_daemon = ref (Obj.magic 0.0) in
        let bits0 = ref 0 in
        let len = Bi_vint.read_uvint ib in
        for i = 1 to len do
          match Bi_io.read_field_hashtag ib with
            | 25521 ->
              field_rc := (
                (
                  read__2
                ) ib
              );
              bits0 := !bits0 lor 0x1;
            | 413400452 ->
              field_daemon := (
                (
                  Ag_ob_run.read_int
                ) ib
              );
              bits0 := !bits0 lor 0x2;
            | _ -> Bi_io.skip ib
        done;
        if !bits0 <> 0x3 then Ag_ob_run.missing_fields [| !bits0 |] [| "rc"; "daemon" |];
        (
          {
            rc = !field_rc;
            daemon = !field_daemon;
          }
         : tmp_file)
)
let read_tmp_file = (
  fun ib ->
    if Bi_io.read_tag ib <> 21 then Ag_ob_run.read_error_at ib;
    let field_rc = ref (Obj.magic 0.0) in
    let field_daemon = ref (Obj.magic 0.0) in
    let bits0 = ref 0 in
    let len = Bi_vint.read_uvint ib in
    for i = 1 to len do
      match Bi_io.read_field_hashtag ib with
        | 25521 ->
          field_rc := (
            (
              read__2
            ) ib
          );
          bits0 := !bits0 lor 0x1;
        | 413400452 ->
          field_daemon := (
            (
              Ag_ob_run.read_int
            ) ib
          );
          bits0 := !bits0 lor 0x2;
        | _ -> Bi_io.skip ib
    done;
    if !bits0 <> 0x3 then Ag_ob_run.missing_fields [| !bits0 |] [| "rc"; "daemon" |];
    (
      {
        rc = !field_rc;
        daemon = !field_daemon;
      }
     : tmp_file)
)
let tmp_file_of_string ?pos s =
  read_tmp_file (Bi_inbuf.from_string ?pos s)
