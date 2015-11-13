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
  end) : TSP_SEARCH =
struct

  open Utils
  open P
  open Opts

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
      | (true, SOME t) => SOME (valOf old_len, fn () => t)
      | (_, _) =>
          let
            val res = find d'
          in
            case res of
              NONE => loop (d', sol, iter+1, SOME (IntInf.fromInt 0), old_len, first_sol, stale_count, stale_thresh)
            | SOME (_,r) =>
                let
                  val t = Search.toVector (r ())
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
                  if ts = first_sol orelse isSome stale_thresh andalso stale_count' >= valOf stale_thresh then
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
    fn () => (loop (dist, NONE, IntInf.fromInt 1, iter_limit, NONE, NONE, IntInf.fromInt 0, stale_thresh), NONE)
  end

end

functor RotSearchFn(Search: TSP_SEARCH) : TSP_SEARCH =
struct

  open Utils

  type tour = word vector
  type optional_params = word option * Search.optional_params

  fun toVector t = t
  fun toString t =
    "<" ^
    (Vector.foldl
      (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+0w1))
      "") t
    ^ ">"

  fun search size dist _ _ (max_rot, opts) =
  let
    fun shift n = fn i => Word.mod (n + i, size)
    fun solve size dist rot opts =
    let
      val trans = shift rot
      val dist' = fn (x,y) => dist(trans x, trans y)
      val sol = #1 ((Search.search size dist' NONE false opts) ())
    in
      case sol of
        NONE => NONE
      | SOME (d,r) => SOME (d, fn () => Vector.map trans (Search.toVector (r ())))
    end
    fun iter size dist rot max_rot sol opts =
      case rot > max_rot of
        true => sol
      | false =>
          let
            val sol' = solve size dist rot opts
            val _ = printErr ("     * Rot yields:  ")
            val _ = printErr ((wordToString o #1 o valOf) sol')
            val _ = printErr "\n"
            val sol'' = case (sol, sol') of
                          (NONE, _) => sol'
                        | (_, NONE) => sol
                        | (SOME (l,_), SOME (l',_)) => if l < l' then sol else sol'
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
