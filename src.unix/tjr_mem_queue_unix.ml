(** memq operations using a mutable queue, and stdlib unix and threads
   (for mutex and condition variables) *)

module Internal = struct
  type 'a queue = {
    q: 'a Queue.t;
    mutex: Mutex.t;
    cvar: Condition.t
  }

  let enqueue ~msg ~q =
    Mutex.lock q.mutex;
    Queue.add msg q.q;
    Condition.signal q.cvar;
    Mutex.unlock q.mutex


  let dequeue q =
    Mutex.lock q.mutex;
    while (Queue.is_empty q.q) do  (* NOTE loop is for multiple readers *)
      Condition.wait q.cvar q.mutex
    done;
    let msg = Queue.take q.q in
    Mutex.unlock q.mutex;
    msg


  let create () = {
    q=Queue.create();
    mutex=Mutex.create ();
    cvar=Condition.create ()
  }
end
open Internal

(** Imperative via unit state_passing monad *)
let make_unix_memq_ops () = {
  memq_enqueue=(fun ~msg ~q -> sp_of_fun(fun () -> (enqueue ~msg ~q,())));
  memq_dequeue=(fun q -> sp_of_fun(fun () -> (dequeue q,())));
  memq_create=(fun () -> sp_of_fun(fun () -> (create (),())));
}

let _ : unit -> ('a, 'a queue, unit state_passing) memq_ops = make_unix_memq_ops
