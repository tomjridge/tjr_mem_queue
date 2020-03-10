open Lwt.Infix
open Tjr_mem_queue.With_lwt.Internal

let total_written = ref 0

let writer ~q =
  let rec loop () = 
    enqueue ~q ~msg:!total_written >>= fun () ->
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

let reader ~q =
  let rec loop () =
    dequeue q >>= fun _n' ->        
    (* Printf.printf "Receiver got %d\n%!" n'; *)
    incr total_read;
    loop()
  in
  loop ()

let q = create ()

let dur = 2.0 

let print_stats () =
  Printf.printf {|
Stats: 
  dur=%.1f total_written=%#d total_read=%#d len(q)=%d%!
|}
    dur !total_written !total_read (Queue.length q.q)


let _ = 
  let writers = [writer ~q; writer ~q; writer ~q] in
  let main = 
    Printf.printf "Running 3 writers and 1 reader for %.1f seconds\n%!" dur;
    Lwt.choose (writers@[
        reader ~q;
        Lwt_unix.sleep dur])
  in
  let main = 
    main >>= fun () -> 
    List.iter Lwt.cancel writers |> fun () ->
    print_stats();
    Lwt.return ()
  in
  Lwt_main.run main

