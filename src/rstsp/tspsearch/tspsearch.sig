(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Search graph traversal implementations shall abide by this interface.
 *)
signature TSP_SEARCH = sig

  type tour

  type optional_params

  val tourToString: tour -> string

  val tourToVector: tour -> word vector

  (**
   * Given problem size, distance function,
   * dot file name, statistics wish and other optional parameters
   * (such as max # of intervals per node for SBGraph)
   * we can produce generic search graph traversal,
   * also returning number of stored nodes, seen node types & unique hashes count.
   * Note: We want lazy solution.
   *)
  val search: word -> (word * word -> word) ->
              string option -> bool -> optional_params ->
              unit -> ((word * (unit -> tour)) option * (word * word * word) option)

end
