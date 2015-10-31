(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature TSP_NODE = sig

  (* we require equality type for memoizatione *)
  eqtype node
  val compare: node * node -> order

  (* even if we use zero-based coordinates internally,
   * this should yield one-bazed representation *)
  val toString: node -> string

end

signature TSP_TOUR = sig

  type tour

  (* even if we use zero-based coordinates internally,
   * this should yield one-bazed representation *)
  val toString: tour -> string

  val toVector: tour -> word vector

end

signature TSP_GRAPH = sig

  eqtype node
  type tour

  structure Node: TSP_NODE where type node = node
  structure Tour: TSP_TOUR where type tour = tour

  val root: node

  (*
   * given a node, resulting tour can either be computed directly -- in
   * "terminal" nodes -- or be chosen from a list of successor nodes -- for
   * this, one will need distance adjustment and tour construction functions
   *)
  datatype descents = TERM of (word * tour) option
                    | DESC of (node * (word -> word) * (tour -> tour)) list

  (*
   * we will need problem size and distance function here
   *)
  val descend: word -> (word * word -> word) -> node -> descents

end
