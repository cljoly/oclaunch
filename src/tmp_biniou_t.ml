(* Auto-generated from "tmp_biniou.atd" *)


type rc_name = string

type rc_entry = { commands: (string * int) }

type tmp_file = { rc: (rc_name * (rc_entry list)) list; daemon: int }
