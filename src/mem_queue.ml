open Memq_intf

(** Construct the memq operations, given an arbitrary monad and mutex *)
let make_memq_ops ~monad_ops ~mutex_ops : ('msg,('mutex,'cvar,'msg)queue,'t) memq_ops =
  let ( >>= ) = monad_ops.bind in 
  let return = monad_ops.return in
  let {create_mutex;create_cvar;lock;signal;unlock;wait} = mutex_ops in

  let memq_enqueue ~msg ~q =
    lock q.mutex >>= fun () ->  
    (* unnecessary lock? but we signal later so we may need to hold the lock *)
    Queue.add msg q.q;
    signal q.cvar >>= fun () ->
    unlock q.mutex >>= fun () -> 
    return ()
  in


  let memq_dequeue q =
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


  let memq_create () = 
    create_mutex () >>= fun mutex -> 
    create_cvar () >>= fun cvar ->
    return {
      q=Queue.create();
      mutex;
      cvar;
    }
  in

  {memq_enqueue;memq_dequeue;memq_create}


(** Construct memq ops, but hide the ['mutex] and ['cvar] types *)
module Make(S:sig
    type mutex
    type cvar
  end) = struct
  open S
  type 'msg qu = (mutex,cvar,'msg)queue
  let make_ops ~monad_ops ~mutex_ops : ('msg, 'msg qu, 't) memq_ops = 
    make_memq_ops ~monad_ops ~mutex_ops
end
