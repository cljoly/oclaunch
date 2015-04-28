(* Auto-generated from "tmp_biniou.atd" *)


type tmp_file = Tmp_biniou_t.tmp_file = { command: string list; number: int }

let validate__1 = (
  fun _ _ -> None
)
let validate_tmp_file : _ -> tmp_file -> _ = (
  fun _ _ -> None
)
let create_tmp_file 
  ~command
  ~number
  () : tmp_file =
  {
    command = command;
    number = number;
  }
