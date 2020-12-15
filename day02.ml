let pred1 lo hi c pw =
  let count = List.init (String.length pw) (String.get pw) |> List.find_all ((=) c) |> List.length in
  lo <= count && count <= hi

let pred2 lo hi c pw =
  (pw.[lo - 1] = c) <> (pw.[hi - 1] = c)

let file_lines_fold (name:string) (comb:'res -> string -> 'res) (init:'res) : 'res =
  let ic = open_in name
  in let try_read () =
    try Some (input_line ic) with End_of_file -> None
  in let rec loop acc =
    match try_read () with Some s -> loop (comb acc s) | None -> close_in ic; acc
  in loop init

let day02 filename part =
  let pred = if part = 1 then pred1 else pred2 in
  let comb passed line =
    if Scanf.sscanf line "%d-%d %c: %s" pred then
      passed + 1
    else
      passed
  in file_lines_fold filename comb 0

let () = 
  let file = Sys.argv.(1) in
  Printf.printf "%d\n" (day02 file 1);
  Printf.printf "%d\n" (day02 file 2);
