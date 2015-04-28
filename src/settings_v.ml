(* Auto-generated from "settings.atd" *)


type rc_file = Settings_t.rc_file = {
  progs: string list;
  settings: string list
}

let validate__1 = (
  fun _ _ -> None
)
let validate_rc_file : _ -> rc_file -> _ = (
  fun _ _ -> None
)
let create_rc_file 
  ~progs
  ~settings
  () : rc_file =
  {
    progs = progs;
    settings = settings;
  }
