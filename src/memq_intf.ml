(** Mem_queue interfaces; don't open *)

(** What we need from mutexes and condition vars *)
type ('mutex,'cvar,'t) mutex_ops = {
  create_mutex : unit -> ('mutex,'t)m;
  create_cvar  : unit -> ('cvar,'t)m;
  lock         : 'mutex -> (unit,'t)m;
  signal       : 'cvar -> (unit,'t)m;  (* FIXME broadcast? *)
  unlock       : 'mutex -> (unit,'t)m;
  wait         : 'mutex -> 'cvar -> (unit,'t)m;
}


(** The queue of messages. NOTE the q field contains a MUTABLE queue *)
type ('mutex,'cvar,'msg) memq = {
  q: 'msg Queue.t;  (** mutable!!!*)
  mutex: 'mutex;
  cvar: 'cvar
}

(* NOTE could substitute 'q with ('mutex,'cvar,'msg) queue *)
(** FIXME for initialization purposes, we may also want a non-monadic
   "create" operation; at the moment it is in the monad because
   mutexes and references are part of the semantic state, as see in
   mutex ops *)
type ('msg,'q,'t) memq_ops = {
  memq_enqueue: msg:'msg -> q:'q -> (unit,'t)m;
  memq_dequeue: 'q -> ('msg,'t)m;
  memq_create: unit -> ('q,'t)m; (** FIXME? *)
}

class type ['msg,'t] memq_as_obj = object
  method enqueue: 'msg -> (unit,'t)m
  method dequeue: unit -> ('msg,'t)m
  method len: unit -> int
end
