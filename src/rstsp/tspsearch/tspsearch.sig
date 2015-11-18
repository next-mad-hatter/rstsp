(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Search graph traversal implementations follow this interface.
 *
 * Note: a graph traversal also provides its own tour type, since it is not necessarily
 * the same type the underlying graph uses -- as in iterative or flip flop search.
 *)
signature TSP_SEARCH = sig

  structure Len : NUMERIC

  type tour

  type optional_params

  val tourToString: tour -> string

  val tourToVector: tour -> word vector

  (**
   * Given problem size, distance function, dot file name, statistics wish and any optional parameters
   * (such as maimum number of intervals per node for SBGraph),
   * returns the traversal function, which, along the tour, can also return
   * statistics such as number of stored nodes, seen node types & unique hashes count.
   *)
  val search: word -> (word * word -> Len.num) -> string option -> bool -> optional_params ->
              unit -> ((Len.num * (unit -> tour)) option * (word * word * word) option)

end
