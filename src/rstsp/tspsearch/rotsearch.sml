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
 * TODO: return rotations' results instead of flushing them to stdout.
 *)
functor RotSearchFn(X : sig
    structure Search: TSP_SEARCH
    val max_perm : word -> word
    (**
     * We will need problem size & permutation's number here.
     *)
    val perm : word -> word -> word -> word
  end ) : TSP_SEARCH =
struct

  structure S = X.Search
  (*
  *)
  structure U = Utils

  structure Len = S.Len

  type tour = word vector

  (**
   * Additionally to any parameters to the initial search,
   * we need a number of permutations to perform, NONE if
   * all permutations are wanted.
   *)
  type optional_params = word option * S.optional_params

  fun tourToVector t = t

  val tourToString = TSPUtils.wvToString 0w1

  (* QUICK EXP: sb reordering *)
  (*
  *)
  fun sbPP size dist =
  let
    fun wgt j = (Len.toInt o dist) (j,0w0) - (Len.toInt o dist) (j,0w1)
    fun cmp (i,j) = Int.compare (wgt i, wgt j)
    val nums = Array.tabulate (Word.toInt size - 2, Word.fromInt)
    val _ = ArrayQSort.sort cmp nums
    val res = Array.array (Word.toInt size,0w0)
    val _ = Array.appi (fn (i,x) => (Array.update (res, Word.toInt (x+0w2), Word.fromInt (i+2)); ())) nums
    val _ = Array.update (res, 1, 0w1)
    val _ = U.printErr "\n A: "
    val _ = Array.app ((fn x => (U.printErr x; U.printErr " ")) o Int.toString o Word.toInt) res
    val _ = U.printErr "\n"
  in
    fn i => Array.sub (res, Word.toInt i)
  end

  fun search size dist _ _ (max_rot, opts) =
  let
    fun solve size dist rot opts =
    let
      (**
       * We wish the first rotation to yield the initial search.
       *)
      val trans = case rot of
                  (*
                    0w0 => (fn i => i)
                  | _   => fn i => X.perm size (rot-0w1)
                  *)
                    0w0 => (fn i => i)
                  | 0w1 => sbPP size dist
                  | _   => X.perm size (rot-0w2)
      val dist' = fn (x,y) => dist(trans x, trans y)
      val sol = #1 ((S.search size dist' NONE false opts) ())
    in
      case sol of
        NONE => NONE
      | SOME (d,r) => SOME (d, fn () => Vector.map trans (S.tourToVector (r ())))
    end
    fun iter size dist rot max_rot sol opts =
      case rot > max_rot of
        true => (U.printErr "\n"; sol)
      | false =>
          let
            val sol' = solve size dist rot opts
            (*
            *)
            val _ = if rot = 0w0 then U.printErr ("Permuting: ") else ()
            val _ = U.printErr ((Len.toString o #1 o valOf) sol')
            val _ = U.printErr " "
            val sol'' = case (sol, sol') of
                          (NONE, _) => sol'
                        | (_, NONE) => sol
                        | (SOME (l,_), SOME (l',_)) => if Len.compare(l,l') = LESS then sol else sol'
          in
            iter size dist (rot+0w1) max_rot sol'' opts
          end
    val max_rot' = 0w1 + (case (max_rot, X.max_perm size) of
                           (NONE,m) => m
                         | (SOME m,m') => Word.min (m,m')
                         )
  in
    fn () => (iter size dist 0w0 max_rot' NONE opts, NONE)
  end

end
