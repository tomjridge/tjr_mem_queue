(** In-memory message queue between eg Lwt threads *)

(** Main functionality: *)

module Memq_intf = Memq_intf

type ('msg,'t) memq_as_obj = ('msg,'t) Memq_intf.memq_as_obj

(* type ('mutex,'cvar,'msg) memq = ('mutex,'cvar,'msg) Memq_intf.memq *)
(* type ('msg,'q,'t) memq_ops = ('msg,'q,'t) Memq_intf.memq *)

module Raw_memq = Raw_memq

module With_lwt = With_lwt
