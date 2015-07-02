(* Auto-generated from "tmp_biniou.atd" *)


type rc_entry = Tmp_biniou_t.rc_entry = { commands: (string * int) }

type tmp_file = Tmp_biniou_t.tmp_file = { rc: rc_entry list; daemon: int }

let validate_rc_entry : _ -> rc_entry -> _ = (
  fun _ _ -> None
)
let validate__1 = (
  fun _ _ -> None
)
let validate_tmp_file : _ -> tmp_file -> _ = (
  fun _ _ -> None
)
let create_rc_entry 
  ~commands
  () : rc_entry =
  {
    commands = commands;
  }
let create_tmp_file 
  ~rc
  ~daemon
  () : tmp_file =
  {
    rc = rc;
    daemon = daemon;
  }
