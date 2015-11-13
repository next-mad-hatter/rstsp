(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

functor LocalSearchFn(
  P: sig
    structure Search: TSP_SEARCH
    structure Opts: sig
      val inv_order: word -> word -> word
    end
  end) =
struct

  open P
  open Opts
  open Utils

  type tour = word vector
  type optional_params = IntInf.int option * IntInf.int option * Search.optional_params

  fun toVector t = t
  fun toString t =
    "<" ^
    (Vector.foldl
      (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+0w1))
      "") t
    ^ ">"

  fun search size dist _ _ (iter_limit, stale_thresh, opts) =
  let
    fun lookup t = fn i => Vector.sub (t, Word.toInt (inv_order size i))
    fun find d' = #1 ((Search.search size d' NONE false opts) ())
    fun loop (d', sol, iter, iter_limit, old_len, first_sol, stale_count, stale_thresh) =
      case (isSome iter_limit andalso iter > valOf iter_limit, sol) of
        (true, NONE) => NONE
      | (true, SOME t) => SOME (fn () => t)
      | (_, _) =>
          let
            val res = find d'
          in
            case res of
              NONE => loop (d', sol, iter+1, SOME (IntInf.fromInt 0), old_len, first_sol, stale_count, stale_thresh)
            | SOME r =>
                let
                  val t = Search.Tour.toVector (r ())
                  val first_sol' = if isSome first_sol then first_sol else SOME t
                  val new_len = tourLength d' t
                  val _ = printErr ("     * Iter yields:  ")
                  val _ = printErr (wordToString new_len)
                  val _ = printErr (" @ ")
                  val _ = printErr (toString t)
                  val _ = printErr "\n"
                  val lu = lookup t
                  val d'' = fn (x,y) => d' (lu x, lu y)
                  val ts = case sol of
                             NONE => SOME t
                           | SOME t' => SOME (Vector.map (lookup t') t)
                  val stale_count' = if isSome old_len andalso new_len = valOf old_len then
                                     stale_count + 1 else stale_count
                in
                  (*
                  *)
                  printErr ("                     -> ");
                  printErr (toString (valOf ts));
                  printErr " (";
                  printErr (wordToString (tourLength dist (valOf ts)));
                  printErr ")\n";
                  if ts = first_sol orelse isSome stale_thresh andalso stale_count' > valOf stale_thresh then
                    loop (d'', ts, iter+1, SOME (IntInf.fromInt 0), SOME new_len, first_sol', stale_count', stale_thresh)
                  else if isSome old_len andalso new_len > valOf old_len then (
                    printErr "WARNING: target increase detected.\n";
                    loop (d', sol, iter+1, SOME (IntInf.fromInt 0), old_len, first_sol', stale_count', stale_thresh)
                    )
                  else
                    loop (d'', ts, iter+1, iter_limit, SOME new_len, first_sol', stale_count', stale_thresh)
                end
          end
  in
    (* TODO: return iterations count / termination reason *)
    fn () => (loop (dist, NONE, IntInf.fromInt 1, iter_limit, NONE, NONE, IntInf.fromInt 0, stale_thresh), SOME (0w0, 0w0, 0w0))
  end

end

