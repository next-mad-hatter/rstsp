(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Given a graph traversal for a TSP, this will apply the search iteratively.
 *
 * Of course, we want to reorder the nodes before each iteration in such a way that
 * while search neighbourhood changes, last best solution is still in scope of next iteration.
 *
 * To this functor we shall provide the inverse of such a reordering function
 * which shall assume last best solution to be (1, ... ,n (1)).
 *
 * TODO: return iterations results instead of flushing them to stdout.
 *)
functor IterSearchFn(
  P: sig
    structure Search: TSP_SEARCH
    (* This will generally depend on problem size. *)
    val inv_order: word -> word -> word
  end) : TSP_SEARCH =
struct

  structure U = Utils
  structure S = P.Search

  structure Cost = S.Cost

  type tour = word vector

  type optional_params = IntInf.int option * IntInf.int option * S.optional_params

  fun tourToVector t = t

  val tourToString = TSPUtils.wvToString 0w1

  fun search size dist _ _ (iter_limit, stale_thresh, opts) =
  let
    fun lookup t = fn i => Vector.sub (t, Word.toInt (P.inv_order size i))
    fun find d' = #1 ((S.search size d' NONE false opts) ())
    fun loop (d', sol, iter, iter_limit, old_cost, stale_count, stale_thresh) =
      case (isSome iter_limit andalso iter > valOf iter_limit, sol) of
        (true, NONE) => NONE
      | (true, SOME t) => SOME (valOf old_cost, fn () => t)
      | (_, _) =>
          let
            val res = find d'
          in
            case res of
              NONE => loop (d', sol, iter+1, SOME (IntInf.fromInt 0), old_cost, stale_count, stale_thresh)
            | SOME (new_cost,r) =>
                let
                  val t = S.tourToVector (r ())
                  val _ = U.printErr ("Iteration:  ")
                  val _ = U.printErr (Cost.toString new_cost)
                  val _ = U.printErr "\n"
                  val lu = lookup t
                  val d'' = fn (x,y) => d' (lu x, lu y)
                  val ts = case sol of
                             NONE => SOME t
                           | SOME t' => SOME (Vector.map (lookup t') t)
                  val stale_count' = if isSome old_cost andalso Cost.compare (new_cost,valOf old_cost) = EQUAL then
                                     stale_count + 1 else IntInf.fromInt 0
                in
                  if isSome stale_thresh andalso stale_count' >= valOf stale_thresh then
                    loop (d'', ts, iter+1, SOME (IntInf.fromInt 0), SOME new_cost, stale_count', stale_thresh)
                  else if isSome old_cost andalso Cost.compare (new_cost,valOf old_cost) = GREATER then (
                    U.printErr "WARNING: target increase detected.\n";
                    loop (d', sol, iter+1, SOME (IntInf.fromInt 0), old_cost, stale_count', stale_thresh)
                    )
                  else
                    loop (d'', ts, iter+1, iter_limit, SOME new_cost, stale_count', stale_thresh)
                end
          end
  in
    fn () => (loop (dist, NONE, IntInf.fromInt 1, iter_limit, NONE, IntInf.fromInt 0, stale_thresh), NONE)
  end

end
