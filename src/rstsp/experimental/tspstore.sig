(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature TSP_STORE =
sig

  type store

  type node
  type tour
  structure Node : TSP_NODE where type node = node
  structure Tour : TSP_TOUR where type tour = tour
  structure Len : NUMERIC

  datatype status = DONE of (Len.num * (unit -> tour)) option
                  | PENDING of Thread.ConditionVar.conditionVar

  val init : word  -> store
  val getToken : store * node -> Thread.Mutex.mutex
  val getStatus : store * node -> status option ref
  val getStats : store -> word * word * word

end
