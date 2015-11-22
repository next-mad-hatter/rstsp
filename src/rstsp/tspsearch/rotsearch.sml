(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Given a graph traversal for a TSP of size n,
 * this applies the traversal to up to n permutations of the TSP.
 *
 * TODO: return rotations' results instead of flushing them to stdout.
 * TODO: allow for more permutations?
 *)
functor RotSearchFn(X : sig structure Search: TSP_SEARCH; val perm : word -> word -> word -> word end ) : TSP_SEARCH =
struct

  structure U = Utils
  structure S = X.Search

  structure Len = S.Len

  type tour = word vector

  (**
   * Additionally to any parameters to the initial search,
   * we need a number of permutations to perform, NONE if
   * all permutations are wanted.
   *
   * Note that this is on top of the natural ordering,
   * thus (SOME 0w0) will yield the initial search.
   *)
  type optional_params = word option * S.optional_params

  fun tourToVector t = t

  val tourToString = TSPUtils.wvToString 0w1

  fun search size dist _ _ (max_rot, opts) =
  let
    fun solve size dist rot opts =
    let
      val trans = X.perm size rot
      val dist' = fn (x,y) => dist(trans x, trans y)
      val sol = #1 ((S.search size dist' NONE false opts) ())
    in
      case sol of
        NONE => NONE
      | SOME (d,r) => SOME (d, fn () => Vector.map trans (S.tourToVector (r ())))
    end
    fun iter size dist rot max_rot sol opts =
      case rot > max_rot of
        true => sol
      | false =>
          let
            val sol' = solve size dist rot opts
            (*
            val _ = U.printErr ("     * Rot yields:  ")
            val _ = U.printErr ((Len.toString o #1 o valOf) sol')
            val _ = U.printErr "\n"
            *)
            val sol'' = case (sol, sol') of
                          (NONE, _) => sol'
                        | (_, NONE) => sol
                        | (SOME (l,_), SOME (l',_)) => if Len.compare(l,l') = LESS then sol else sol'
          in
            iter size dist (rot+0w1) max_rot sol'' opts
          end
    val max_rot' = case max_rot of
                     NONE => size-0w1
                   | SOME m => Word.min (m,size-0w1)
  in
    fn () => (iter size dist 0w0 max_rot' NONE opts, NONE)
  end

end
