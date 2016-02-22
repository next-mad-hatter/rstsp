(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure TSPUtils =
struct

  (**
   * Commonly needed word vector -> string conversion.
   *)
  fun wvToString base t =
    "<" ^
    (Vector.foldl (fn (x,s) => s ^ (if s = "" then "" else " ") ^ Utils.wordToString (x+base)) "") t
    ^ ">"

  (**
   * Checks if v = zero-based permutation of given size + its first element.
   *)
  fun validTour size v =
  let
    val vectorToList = Vector.foldl (op::) []
    val gt = fn (x: word, y) => x > y
    val l = List.tabulate (Word.toInt size, fn i => Word.fromInt i)
  in
    Vector.length v > 1 andalso Vector.sub (v,0) = Vector.sub (v, (Vector.length v) - 1) andalso
    l = ((ListMergeSort.sort gt) o vectorToList) (VectorSlice.concat [VectorSlice.slice (v, 1, NONE)])
  end

  (**
   * Transformation from (row,col) coordinates onto a flat vector (all zero-based)
   * containing lower triangular part (including the diagonal) of a matrix, rows concatenated.
   *)
  fun flatCoor (row:word,col:word) =
    if row >= col then Word.toInt (Word.div (row*(row+0w1),0w2) + col)
                  else flatCoor (col,row)

end

signature TSP_COST =
sig

  structure Dist : DISTANCE

  val tourCost : Dist.dist -> word vector -> Dist.Num.num

end

functor TSPCostFn(D : DISTANCE) : TSP_COST =
struct

  structure Dist = D

  fun tourCost dist v =
    if Vector.length v < 2 then raise Fail "Trivial paths cannot have a cost"
    else
      #2 (Vector.foldl
        (fn (q,(p,s)) =>
        (SOME q,if isSome p then D.Num.+ (s, D.getDist dist (q,valOf p)) else s))
        (NONE, D.Num.zero) v)

end
