open System

let valid target window =
  let pairs = seq { for x in window do for y in window do if x <> y && x + y = target then yield (x, y) } in
  (Seq.length pairs) <> 0

let part1 input =
  let rec loop all =
    let window = all |> Seq.truncate 25 |> Seq.cache in
    let next = all |> Seq.item 25 in
    if not (valid next window) then next else loop (Seq.tail all)
  in 
  loop input

let part2 input part1answer =
  let a =  input in
  let N = Seq.length a in
  seq {
    for n = 2 to N do
      for i = 0 to (N - 1 - n) do
        let s = a |> Seq.skip i |> Seq.take n
        if (Seq.sum s) = part1answer then
          yield (Seq.min s) + (Seq.max s)
  } |> Seq.head

let private main (args:string[]) : int =
  let filename = args.[0] in
  let input = seq { for line in IO.File.ReadAllLines filename do yield int64 line } |> Seq.cache in
  let part1answer = part1 input in
  printfn "%d" part1answer
  let part2answer = part2 input part1answer in
  printfn "%d" part2answer
  0

#if INTERACTIVE
fsi.CommandLineArgs |> Array.toList |> List.tail |> List.toArray |> main
#else
[<EntryPoint>]
let entryPoint args = main args
#endif
