open Lwt.Infix

module Internal = struct
  type 'a queue = {
    q: 'a Queue.t;
    mutex: Lwt_mutex.t;
    cvar: unit Lwt_condition.t
  }


  let enqueue ~msg ~q =
    Lwt_mutex.lock q.mutex >>= fun () ->  (* unnecessary lock? but we signal later so we may need to hold the lock *)
    Queue.add msg q.q;
    Lwt_condition.signal q.cvar ();
    Lwt_mutex.unlock q.mutex;
    Lwt.return ()


  let dequeue q =
    Lwt_mutex.lock q.mutex >>= fun () ->  (* unnecessary lock? but we need to wait later *)
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
end
open Internal
open Tjr_monad.With_lwt

let make_lwt_memq_ops () = {
  memq_enqueue=(fun ~msg ~q -> enqueue ~msg ~q |> from_lwt) ;
  memq_dequeue=(fun q -> dequeue q |> from_lwt);
  memq_create=(fun () -> 
      create () |> lwt_monad_ops.return)
}
