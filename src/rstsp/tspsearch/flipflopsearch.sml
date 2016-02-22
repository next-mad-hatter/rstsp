(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * FIXME: can we restrict Search'.Cost = Search''.Cost here?
 * TODO: factor out common functionality of this & iterative search (& rot search?)
 *)
functor FlipFlopSearchFn(
  P: sig
    structure Search': TSP_SEARCH where type tour = word vector
    val inv_order' : word -> word -> word
    structure Search'': TSP_SEARCH where type Cost.num = Search'.Cost.num where type tour = Search'.tour
    val inv_order'' : word -> word -> word
  end) : TSP_SEARCH =
struct

  structure U = Utils

  structure Cost = P.Search'.Cost

  type tour = P.Search'.tour

  type optional_params = IntInf.int option * IntInf.int option *
                         P.Search'.optional_params * P.Search''.optional_params

  fun tourToVector t = t

  val tourToString = P.Search'.tourToString

  fun search size dist _ _ (iter_limit, stale_thresh, opts', opts'') =
  let
    fun lookup order t = fn i => Vector.sub (t, Word.toInt (order size i))
    fun find iter d' = #1 ((case iter mod 2 of
                              0 => P.Search'.search size d' NONE false opts'
                            | _ => P.Search''.search size d' NONE false opts''
                           ) ())
    fun loop (d', sol, iter, iter_limit, old_cost, stale_count, stale_thresh) =
      case (isSome iter_limit andalso iter > valOf iter_limit, sol) of
        (true, NONE) => NONE
      | (true, SOME t) => SOME (valOf old_cost, fn () => t)
      | (_, _) =>
          let
            val res = find iter d'
          in
            case res of
              NONE => loop (d', sol, iter+1, SOME (IntInf.fromInt 0), old_cost, stale_count, stale_thresh)
            | SOME (new_cost,r) =>
                let
                  val t = (if iter mod 2 = 0 then P.Search'.tourToVector else P.Search''.tourToVector) (r ())
                  val _ = U.printErr (if iter mod 2 = 0 then "Flop:  " else "Flip:  ")
                  val _ = U.printErr (Cost.toString new_cost)
                  val _ = U.printErr "\n"
                  fun lu iter = lookup (if iter mod 2 = 0 then P.inv_order' else P.inv_order'')
                  val d'' = fn (x,y) => d' (lu (iter+1) t x, lu (iter+1) t y)
                  val ts = case sol of
                             NONE => SOME t
                           | SOME t' => SOME (Vector.map (lu iter t') t)
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
