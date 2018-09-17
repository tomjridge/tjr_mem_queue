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


let dequeue ~q =
  Mutex.lock q.mutex;
  while (Queue.is_empty q.q) do
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

