(* open Tjr_monad *)
open Tjr_monad.Monad

type ('msg,'q,'t) queue_ops = {
  enqueue: msg:'msg -> q:'q -> (unit,'t)m;
  dequeue: q:'q -> ('msg,'t)m;
  create: unit -> ('q,'t)m;
}

type ('mutex,'cvar,'t) mutex_ops = {
  create_mutex: unit -> ('mutex,'t)m;
  create_cvar: unit -> ('cvar,'t)m;
  lock : 'mutex -> (unit,'t)m;
  signal: 'cvar -> (unit,'t)m;  (* FIXME broadcast? *)
  unlock: 'mutex -> (unit,'t)m;
  wait: 'mutex -> 'cvar -> (unit,'t)m;
}


type ('mutex,'cvar,'a) queue = {
  q: 'a Queue.t;
  mutex: 'mutex;
  cvar: 'cvar
}
           

let make_ops ~monad_ops ~mutex_ops =
  let ( >>= ) = monad_ops.bind in 
  let return = monad_ops.return in
  let {create_mutex;create_cvar;lock;signal;unlock;wait} = mutex_ops in

  let enqueue ~msg ~q =
    lock q.mutex >>= fun () ->  (* unnecessary lock? but we signal later so we may need to hold the lock *)
    Queue.add msg q.q;
    signal q.cvar >>= fun () ->
    unlock q.mutex >>= fun () -> 
    return ()
  in


  let dequeue ~q =
    lock q.mutex >>= fun () ->  (* unnecessary lock? but we need to wait later *)
    let rec loop () = 
      if Queue.is_empty q.q 
      then wait q.mutex q.cvar >>= fun () -> loop ()
      else return ()
    in
    loop () >>= fun () ->
    let msg = Queue.take q.q in
    unlock q.mutex >>= fun () ->
    return msg
  in


  let create () = 
    create_mutex () >>= fun mutex -> 
    create_cvar () >>= fun cvar ->
    return {
      q=Queue.create();
      mutex;
      cvar;
    }
  in

  {enqueue;dequeue;create}
