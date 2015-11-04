(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature TSP_SEARCH = sig

  type tour
  type optional_params

  structure Tour: TSP_TOUR where type tour = tour

  (* given problem size, distance function,
   * dot file name, number of nodes wish and other optional parameters
   * (such as max # of intervals per node for SBGraph)
   * we can produce generic search graph traversal,
   * also returning number of stored nodes & seen node types.
   *)
  val search: word -> (word * word -> word) ->
              string option -> bool -> optional_params ->
              unit -> (tour option * (word * word) option)

end
