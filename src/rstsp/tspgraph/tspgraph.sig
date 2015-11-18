(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * In a general TSP search graph:
 *
 *   - a graph node shall represent a set of tours;
 *
 *   - descendancy represents the subset relation;
 *
 *   - for terminal nodes, we should be able to compute
 *     a best tour efficiently;
 *
 *   - for non-terminals, we can choose from best tours
 *     (possibly transformed) the particular node's
 *     descendants yield;
 *
 *   - we are generally interested in a best tour for the root set.
 *)


signature TSP_NODE = sig

  type node

  (**
   * We usually want to see one-based representation here.
   *)
  val toString: node -> string

  (**
   * The key to be used for memoization -- this does not
   * necessarily have to be the whole node -- as in, e.g.,
   * SB graph, where those contain suprfluous information
   * for speed reasons.
   *)
  eqtype key

  val compare: key * key -> order

  val toKey: node -> key

  (**
   * Pyramidal/SB graph specific: level-agnostic representation.
   * If we were to add other node types, we would have to lift the type.
   * For now, this will have do.
   *)
  val normKey: key -> TSPTypes.WordPairSet.set

  (**
   * In case a hash table is to be used for memoization,
   * we'll need a hashing function -- which, in general,
   * will depend on problem size.
   *)
  val toHash: word -> key -> word

end


signature TSP_TOUR = sig

  type tour

  val toString: tour -> string

  (**
   * A tour does not necessarily have to be connected.
   * However, this will only be called in cases where
   * it is reasonable to expect such a condition to hold --
   * such as on the root node.
   *)
  val toVector: tour -> word vector

end


signature TSP_GRAPH = sig

  type node
  type tour

  (**
   * Type of tour lengths.
   *)
  structure Len : NUMERIC

  structure Node: TSP_NODE where type node = node
  structure Tour: TSP_TOUR where type tour = tour

  val root: node

  (**
   * Given a node, best tour from the set it represents can either be
   *
   *   - computed directly -- for terminal nodes;
   *     we will return tour length along with (lazily) the tour
   *     where a solution exists and NONE otherwise;
   *
   *   - chosen from the tours yielded by descendent nodes and then transformed
   *     as necessary -- to allow for such transformations, we will need to pass
   *     distance adjustment and tour construction functions.
   *)
  datatype descent = TERM of (Len.num * (unit -> tour)) option
                   | DESC of (node * (Len.num -> Len.num)
                                   * ((unit -> tour) -> (unit -> tour))) list

  (**
   * Any information we should need for specific graphs shall go here.
   *)
  type optional_params

  (**
   * This shall compute the descendants and ascendent transfomations --
   * we will generally want to know problem size and distance function here.
   *)
  val descendants: word -> (word * word -> Len.num) -> optional_params ->
                   node -> descent

  (**
   * In case a hash table is to be used for memoization, we would like to
   * have a guess as to initial table size.
   *)
  val HTSize: word * optional_params -> word

end
