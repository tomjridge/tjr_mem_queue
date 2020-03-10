(** Like test_lwt_raw, but using the obj interface; pulling out enq
   and deq gives slight performance adv, and obj interface is close to
   plain records *)

open Lwt.Infix
open Tjr_mem_queue.Memq_intf
open Tjr_mem_queue.With_lwt

let to_lwt = Tjr_monad.With_lwt.to_lwt

let total_written = ref 0

let writer q =
  let enqueue = q#enqueue in
  let rec loop () = 
    to_lwt (enqueue !total_written) >>= fun () ->
    incr total_written;
    begin 
      (!total_written mod 1000 = 0) |> function 
      | true -> Lwt.pause ()
      | false -> Lwt.return ()
    end
    >>= fun () -> loop ()
  in
  loop ()

let total_read = ref 0

let reader q =
  let dequeue = q#dequeue in
  let rec loop () =
    to_lwt (dequeue ()) >>= fun _n' ->        
    (* Printf.printf "Receiver got %d\n%!" n'; *)
    incr total_read;
    loop()
  in
  loop ()

let q : (_,_) memq_as_obj = make_as_object ()

let dur = 2.0 

let print_stats () =
  Printf.printf {|
Stats: 
  dur=%.1f total_written=%#d total_read=%#d len(q)=%d%!
|}
    dur !total_written !total_read (q#len ())


let _ = 
  let writers = [writer q; writer q; writer q] in
  let main = 
    Printf.printf "Running 3 writers and 1 reader for %.1f seconds\n%!" dur;
    Lwt.choose (writers@[
        reader q;
        Lwt_unix.sleep dur])
  in
  let main = 
    main >>= fun () -> 
    List.iter Lwt.cancel writers |> fun () ->
    print_stats();
    Lwt.return ()
  in
  Lwt_main.run main

