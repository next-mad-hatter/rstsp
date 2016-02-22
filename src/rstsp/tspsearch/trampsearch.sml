(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Trampolines a given search from given initial tour.
 *)
functor TrampSearchFn(
  P: sig
    structure Search: TSP_SEARCH
    (* This will generally depend on problem size. *)
    val shuffle: word -> word -> word
  end) : TSP_SEARCH =
struct

  structure S = P.Search

  structure Cost = S.Cost

  type tour = word vector

  type optional_params = word vector option * S.optional_params

  fun tourToVector t = t

  val tourToString = TSPUtils.wvToString 0w1

  fun search size dist dotlog wants_stats (tour, opts) =
    case tour of
      NONE =>
        let
          val (res,stats) = (S.search size dist dotlog wants_stats opts) ()
        in
          case res of
            NONE => (fn () => (NONE, stats))
          | SOME (cost,t) => (fn () => (SOME (cost, Lazy.susp (fn () => S.tourToVector (t ()))), stats))
        end
    | SOME tour' =>
        let
          val _ = if Vector.length tour' = 1 + Word.toInt size then () else raise Fail "trampoline dimension mismatch"
          fun lookup i = Vector.sub (tour', Word.toInt (P.shuffle size i))
          fun dist' (x,y) = dist (lookup x, lookup y)
          val (res,stats) = (S.search size dist' dotlog wants_stats opts) ()
        in
          case res of
            NONE => (fn () => (NONE, stats))
          | SOME (cost,t) => (fn () => (SOME (cost, Lazy.susp (fn () => Vector.map lookup (S.tourToVector (t ())))), stats))
        end

end
