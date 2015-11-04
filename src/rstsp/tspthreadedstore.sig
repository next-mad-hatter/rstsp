(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature TSP_THREADED_STORE =
sig

  type store

  type node
  type tour
  structure Node: TSP_NODE where type node = node
  structure Tour: TSP_TOUR where type tour = tour

  datatype status = DONE of (word * tour) option
                  | PENDING of Thread.ConditionVar.conditionVar

  (* init: problem size, new-type-log message *)
  (*
  val init: word * ((node -> string) option) -> store
  *)
  val init: word  -> store
  val getToken: store * node -> Thread.Mutex.mutex
  val getStatus: store * node -> status option ref

end
