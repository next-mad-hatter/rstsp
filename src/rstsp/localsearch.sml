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
      val iter_limit: IntInf.int
      val inv_order: word -> word -> word
    end
  end) =
struct

  open P
  open Opts
  open Utils

  type tour = word vector

  fun toVector t = t
  fun toString t =
    "<" ^
    (Vector.foldl
      (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+0w1))
      "") t
    ^ ">"

  fun search size dist _ _ opts =
  let
    fun lookup t = fn i => Vector.sub (t, Word.toInt (inv_order size i))
    fun find d' = #1 ((Search.search size d' NONE false opts) ())
    fun loop (d', sol, iter, old_len) =
      case (iter > iter_limit, sol) of
        (true, NONE) => NONE
      | (true, SOME t) => SOME (fn () => t)
      | (_, ts) =>
          let
            val res = find d'
          in
            case res of
              NONE => loop (d', sol, iter_limit + 1, old_len)
            | SOME r =>
                let
                  val t = Search.Tour.toVector (r ())
                  val new_len = tourLength d' t
                  val _ = print ("LOCAL SOLUTION: ")
                  (*
                  val _ = print (toString t)
                  val _ = print " : "
                  *)
                  val _ = print (wordToString new_len)
                  val _ = print "\n"
                  val lu = lookup t
                  val d'' = fn (x,y) => d' (lu x, lu y)
                  val ts = case sol of
                             NONE => SOME t
                           | SOME t' => SOME (Vector.map (lookup t') t)
                in
                  (*
                  print ("TRANSFORMED SOLUTION: ");
                  print (toString (valOf ts));
                  print " : ";
                  print (wordToString (tourLength dist (valOf ts)));
                  print "\n";
                  *)
                  (* TODO: count stale iterations *)
                  if isSome old_len andalso new_len = valOf old_len then
                    loop (d'', ts, iter_limit+1, SOME new_len)
                  else
                    loop (d'', ts, iter+1, SOME new_len)
                end
          end
  in
    (* TODO: return iterations count / termination reason *)
    fn () => (loop (dist, NONE, IntInf.fromInt 1, NONE), SOME (0w0, 0w0, 0w0))
  end

end

