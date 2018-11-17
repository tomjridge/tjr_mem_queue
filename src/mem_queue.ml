(* open Tjr_monad *)
open Tjr_monad.Types
include Types

let make_ops ~monad_ops ~mutex_ops : ('msg,('mutex,'cvar,'msg)queue,'t) queue_ops =
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


(** Hide the ['mutex] and ['cvar] types *)
module Make(S:sig
type mutex
type cvar
end) = struct
  open S
  type 'msg qu = (mutex,cvar,'msg)queue
  let make_ops ~monad_ops ~mutex_ops : ('msg, 'msg qu, 't) queue_ops = make_ops ~monad_ops ~mutex_ops
end
