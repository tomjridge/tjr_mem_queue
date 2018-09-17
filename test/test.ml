open Tjr_mem_queue

let writer ~q =
  let _ = Thread.create 
      (fun _ -> 
         let n = ref 0 in
         let rec loop () = 
           enqueue ~q ~msg:!n;
           n:=!n+1;
           (* Thread.delay (Random.float 0.1); *)
           Thread.yield();
           loop ()
         in
         loop())
      ()
  in
  ()

let reader ~q ~n =
  let _ = Thread.create 
      (fun _ -> 
         let rec loop () =
           let n' : int = dequeue ~q in        
           (* Printf.printf "Receiver got %d\n%!" n'; *)
           n:=!n+1;
           loop()
         in
         loop())
      ()
  in
  ()

let q = create ()

let n = ref 0 

let _ = 
  writer ~q;
  writer ~q;
  writer ~q;
  reader ~q ~n;
  Thread.delay 10.0

let _ =
  Printf.printf "Reader received a total of: %d\n%!" !n

(*
Without printing:
$ test $ ./test.native  
Reader received a total of: 63351584

This is for 10s, so 6M per second, or 1/6 * 10^-6 for each call
*)



(*
Local Variables:
compile-command: "ocamlfind ocamlopt -thread -package tjr_mem_queue -linkpkg -o test.native test.ml"
End:
*)
