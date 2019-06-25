(** In-memory message queue between eg Lwt threads *)

(** Main functionality: *)

module Memq_intf = Memq_intf

include Memq_intf.Export

include Mem_queue 

