(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Given a graph traversal for a TSP of size n, this applies the traversal to
 * up to max_perm(n) permutations of the TSP -- enumerated by the permute function --
 * in addition to canonical ordering.
 *
 * We shall call the permutations which define the flower "rotations",
 * hence the functor name.
 *
 * TODO: return rotations' results instead of flushing them to stdout.
 *)
functor RotSearchFn(X : sig
    structure Search: TSP_SEARCH
    (* We will need problem size & permutation's number here. *)
    val permute : word -> word -> word -> word
    (* And problem size here. *)
    val max_perm : word -> word
  end ) : TSP_SEARCH =
struct

  structure S = X.Search
  structure U = Utils

  structure Cost = S.Cost

  type tour = word vector

  (**
   * Additionally to any parameters to the initial search,
   * we need the number of permutations to perform, NONE if
   * all permutations are wanted -- and permutations offset
   * (for adaptive search).
   *)
  type optional_params = word option * word * S.optional_params

  fun tourToVector t = t

  val tourToString = TSPUtils.wvToString 0w1

  fun search size dist _ _ (max_rot, offset, opts) =
  let

    fun solve size dist rot opts =
    let
      (**
       * We wish the first rotation to yield the initial search.
       *)
      val trans = case rot of
                    0w0 => (fn i => i)
                  | _   => X.permute size (rot-0w1)
      val dist' = fn (x,y) => dist(trans x, trans y)
      val sol = #1 ((S.search size dist' NONE false opts) ())
    in
      case sol of
        NONE => NONE
      | SOME (d,r) => SOME (d, Lazy.susp (fn () => Vector.map trans (S.tourToVector (r ()))))
    end

    fun iter size dist rot offset max_rot sol opts =
      case rot > max_rot of
        true => (U.printErr "\n"; sol)
      | false =>
          let
            val sol' = solve size dist rot opts
            val _ = if rot = 0w0 then U.printErr ("Permuting: ") else ()
            val _ = U.printErr ((Cost.toString o #1 o valOf) sol')
            val _ = U.printErr " "
            val sol'' = case (sol, sol') of
                          (NONE, _) => sol'
                        | (_, NONE) => sol
                        | (SOME (l,_), SOME (l',_)) => if Cost.compare(l,l') = LESS then sol else sol'
            val rot' = if rot = 0w0 then 0w1+offset else rot+0w1
          in
            iter size dist rot' offset max_rot sol'' opts
          end

    val max_rot' = case (max_rot, X.max_perm size) of
                     (NONE,m) => m
                   | (SOME m,m') => Word.min (m,m')

  in
    fn () => (iter size dist 0w0 offset max_rot' NONE opts, NONE)
  end

end
