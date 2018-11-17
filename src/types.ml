(* open Tjr_monad *)
open Tjr_monad.Types


type ('mutex,'cvar,'t) mutex_ops = {
  create_mutex: unit -> ('mutex,'t)m;
  create_cvar: unit -> ('cvar,'t)m;
  lock : 'mutex -> (unit,'t)m;
  signal: 'cvar -> (unit,'t)m;  (* FIXME broadcast? *)
  unlock: 'mutex -> (unit,'t)m;
  wait: 'mutex -> 'cvar -> (unit,'t)m;
}


type ('mutex,'cvar,'msg) queue = {
  q: 'msg Queue.t;
  mutex: 'mutex;
  cvar: 'cvar
}

(* NOTE could substitute 'q with ('mutex,'cvar,'msg) queue *)
(* FIXME for initialization purposes, we may also want a non-monadic
   "create" operation *)
type ('msg,'q,'t) queue_ops = {
  enqueue: msg:'msg -> q:'q -> (unit,'t)m;
  dequeue: q:'q -> ('msg,'t)m;
  create: unit -> ('q,'t)m;
}

