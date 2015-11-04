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
  structure Node: TSP_NODE where type node = node
  structure Tour: TSP_TOUR where type tour = tour

  (* depends on problem size *)
  val init: word -> store
  val getResult: store * node -> (word * tour) option option
  val setResult: store * node * ((word * tour) option ) -> unit

end
