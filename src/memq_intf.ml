
type ('mutex,'cvar,'t) mutex_ops = {
  create_mutex: unit -> ('mutex,'t)m;
  create_cvar: unit -> ('cvar,'t)m;
  lock : 'mutex -> (unit,'t)m;
  signal: 'cvar -> (unit,'t)m;  (* FIXME broadcast? *)
  unlock: 'mutex -> (unit,'t)m;
  wait: 'mutex -> 'cvar -> (unit,'t)m;
}


(** NOTE the q field contains a mutable queue *)
type ('mutex,'cvar,'msg) queue = {
  q: 'msg Queue.t;  (* mutable!!!*)
  mutex: 'mutex;
  cvar: 'cvar
}

module Export = struct
  (* NOTE could substitute 'q with ('mutex,'cvar,'msg) queue *)
  (* FIXME for initialization purposes, we may also want a non-monadic
     "create" operation *)
  type ('msg,'q,'t) memq_ops = {
    memq_enqueue: msg:'msg -> q:'q -> (unit,'t)m;
    memq_dequeue: 'q -> ('msg,'t)m;
    memq_create: unit -> ('q,'t)m;
  }
end
include Export
