open Tjr_mem_queue

let writer ~q =
  let _ = Thread.create 
      (fun _ -> 
         let n = ref 0 in
         let rec loop () = 
           enqueue ~q ~msg:!n;
           n:=!n+1;
           Thread.delay (Random.float 0.1);
           loop ()
         in
         loop())
      ()
  in
  ()

let reader ~q =
  let _ = Thread.create 
      (fun _ -> 
         let rec loop () =
           let n : int = dequeue ~q in        
           Printf.printf "Receiver got %d\n%!" n;
           loop()
         in
         loop())
      ()
  in
  ()

let q = create ()

let _ = 
  writer ~q;
  writer ~q;
  writer ~q;
  reader ~q;
  Thread.delay 10.0

(*
Local Variables:
compile-command: "ocamlfind ocamlopt -thread -package tjr_mem_queue -linkpkg -o test.native test.ml"
End:
*)
