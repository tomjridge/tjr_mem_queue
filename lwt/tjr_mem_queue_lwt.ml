open Lwt.Infix

type 'a queue = {
  q: 'a Queue.t;
  mutex: Lwt_mutex.t;
  cvar: unit Lwt_condition.t
}
           

let enqueue ~msg ~q =
  Lwt_mutex.lock q.mutex >>= fun () ->  (* unnecessary lock *)
  Queue.add msg q.q;
  Lwt_condition.signal q.cvar ();
  Lwt_mutex.unlock q.mutex;
  Lwt.return ()


let dequeue ~q =
  Lwt_mutex.lock q.mutex >>= fun () ->  (* unnecessary lock *)
  let rec loop () = 
    if Queue.is_empty q.q 
    then Lwt_condition.wait ~mutex:q.mutex q.cvar >>= fun () -> loop ()
    else Lwt.return ()
  in
  loop () >>= fun () ->
  let msg = Queue.take q.q in
  Lwt_mutex.unlock q.mutex;
  Lwt.return msg


let create () = {
  q=Queue.create();
  mutex=Lwt_mutex.create ();
  cvar=Lwt_condition.create ()
}

