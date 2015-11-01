(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

fun tourLength dist v =
  if Vector.length v < 2 then raise Fail "Trivial paths have no length"
  else
    #2 (Vector.foldl
      (fn (q,(p,s)) =>
      (SOME q,if isSome p then s + dist (q,valOf p) else s))
      (NONE,0w0) v)

fun validTour size v =
let
  val vectorToList = Vector.foldl (op::) []
  val gt = fn (x: word, y) => x > y
  val l = List.tabulate (Word.toInt size, fn i => Word.fromInt i)
in
  Vector.length v > 1 andalso Vector.sub (v,0) = Vector.sub (v, (Vector.length v) - 1) andalso
  l = ((ListMergeSort.sort gt) o vectorToList) (VectorSlice.concat [VectorSlice.slice (v, 1, NONE)])
end
