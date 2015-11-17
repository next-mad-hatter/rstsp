(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure TSPUtils =
struct

  fun wvToString base t =
    "<" ^
    (Vector.foldl (fn (x,s) => s ^ (if s = "" then "" else " ") ^ Utils.wordToString (x+base)) "") t
    ^ ">"

  fun validTour size v =
  let
    val vectorToList = Vector.foldl (op::) []
    val gt = fn (x: word, y) => x > y
    val l = List.tabulate (Word.toInt size, fn i => Word.fromInt i)
  in
    Vector.length v > 1 andalso Vector.sub (v,0) = Vector.sub (v, (Vector.length v) - 1) andalso
    l = ((ListMergeSort.sort gt) o vectorToList) (VectorSlice.concat [VectorSlice.slice (v, 1, NONE)])
  end

end

signature TSP_LENGTH =
sig

  structure Dist : DISTANCE

  val tourLength : Dist.dist -> word vector -> Dist.Num.num

end

functor TSPLengthFn(D : DISTANCE) : TSP_LENGTH =
struct

  structure Dist = D

  fun tourLength dist v =
    if Vector.length v < 2 then raise Fail "Trivial paths have no length"
    else
      #2 (Vector.foldl
        (fn (q,(p,s)) =>
        (SOME q,if isSome p then D.Num.+ (s, D.getDist dist (q,valOf p)) else s))
        (NONE, D.Num.zero) v)

end
