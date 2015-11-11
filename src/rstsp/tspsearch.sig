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

  val toString: tour -> string

  val toVector: tour -> word vector

  (* given problem size, distance function,
   * dot file name, statistics wish and other optional parameters
   * (such as max # of intervals per node for SBGraph)
   * we can produce generic search graph traversal,
   * also returning number of stored nodes, seen node types & unique hashes count.
   * Note: We want lazy solution.
   *)
  val search: word -> (word * word -> word) ->
              string option -> bool -> optional_params ->
              unit -> ((unit -> tour) option * (word * word * word) option)

end
