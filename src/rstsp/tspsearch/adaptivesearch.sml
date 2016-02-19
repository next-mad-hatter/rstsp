(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * A combination of iterative & rot searches where number of rotations
 * increases with stale iterations according to rate given by the `increase` function.
 *
 * TODO: return iterations' results instead of flushing them to stdout.
 *)
functor AdSearchFn(
  P: sig
    structure Search: TSP_SEARCH
    val inv_order: word -> word -> word
    val permute : word -> word -> word -> word
    val max_perm : word -> word
    val increase : word -> word
  end) : TSP_SEARCH =
struct

  structure U = Utils

  structure S = RotSearchFn(
    struct
      structure Search = P.Search
      val permute = P.permute
      val max_perm = P.max_perm
    end
  )

  structure Cost = S.Cost

  type tour = word vector

  type optional_params = IntInf.int option * IntInf.int option * word * word option * P.Search.optional_params

  fun tourToVector t = t

  val tourToString = TSPUtils.wvToString 0w1

  fun search size dist _ _ (iter_limit, stale_thresh, min_rot, max_rot, opts) =
  let

    fun lookup t = fn i => Vector.sub (t, Word.toInt (P.inv_order size i))

    fun find offset rot d' = #1 ((S.search size d' NONE false (SOME rot,offset,opts)) ())

    fun loop (d', sol, iter, iter_limit, old_cost, stale_count, stale_thresh, rot, offset, max_rot) =
      case (isSome iter_limit andalso iter > valOf iter_limit, sol) of
        (true, NONE) => NONE
      | (true, SOME t) => SOME (valOf old_cost, fn () => t)
      | (_, _) =>
          let
            val res = find offset rot d'
          in
            case res of
              NONE => loop (d', sol, iter+1, SOME (IntInf.fromInt 0), old_cost, stale_count, stale_thresh, rot, offset, max_rot)
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
                  val rot' = if isSome old_cost andalso Cost.compare (new_cost,valOf old_cost) = EQUAL then
                             Word.min (P.increase rot,max_rot) else rot
                  val offset' = if rot' > rot then rot else 0w0
                  val stale_count' = if isSome old_cost andalso Cost.compare (new_cost,valOf old_cost) = EQUAL andalso rot >= rot' then
                                     stale_count + 1 else IntInf.fromInt 0
                in
                  if isSome stale_thresh andalso stale_count' >= valOf stale_thresh then
                    loop (d'', ts, iter+1, SOME (IntInf.fromInt 0), SOME new_cost, stale_count', stale_thresh, rot', offset', max_rot)
                  else if isSome old_cost andalso Cost.compare (new_cost,valOf old_cost) = GREATER then (
                    U.printErr "WARNING: target increase detected.\n";
                    loop (d', sol, iter+1, SOME (IntInf.fromInt 0), old_cost, stale_count', stale_thresh, rot', offset', max_rot)
                    )
                  else
                    loop (d'', ts, iter+1, iter_limit, SOME new_cost, stale_count', stale_thresh, rot', offset', max_rot)
                end
          end

    val max_rot' = case max_rot of
                     NONE => P.max_perm size
                   | SOME m => Word.min(P.max_perm size, m)

  in
    fn () => (loop (dist, NONE, IntInf.fromInt 1, iter_limit, NONE, IntInf.fromInt 0, stale_thresh, min_rot, 0w0, max_rot'), NONE)
  end

end
