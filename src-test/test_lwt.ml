open Lwt.Infix
open Tjr_mem_queue.With_lwt.Internal

let writer ~q =
  let n = ref 0 in
  let rec loop () = 
    enqueue ~q ~msg:!n >>= fun () ->
    n:=!n+1;
    if !n mod 1000 = 0 then
      Lwt.pause () >>= fun () ->
      loop ()
    else
      loop ()
  in
  loop ()

let reader ~q ~n =
  let rec loop () =
    dequeue q >>= fun _n' ->        
    (* Printf.printf "Receiver got %d\n%!" n'; *)
    n:=!n+1;
    loop()
  in
  loop ()

let q = create ()

let n = ref 0 

let _ = 
  let writers = [writer ~q; writer ~q; writer ~q] in
  let _r = reader ~q ~n in
  let main = 
    Lwt_unix.sleep 10.0 >>= fun () ->
    List.map Lwt.cancel writers |> fun _ ->
    Lwt.return ()
  in
  Lwt_main.run main

let _ =
  Printf.printf "Reader received a total of: %d\n%!" !n


(*

$ test $ ./test_lwt.native 
Reader received a total of: 10430802

*)


