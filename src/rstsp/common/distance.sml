(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature DISTANCE =
sig
  structure Num : NUMERIC

  type dist
  val getDist : dist -> word * word -> Num.num
  val getDim : dist -> word
end

(**
 * Flat vector containing lower triangular part
 * of a matrix, rows concatenated.
 *)
structure NatDist : DISTANCE =
struct

  structure Num = WordNum

  type dist = word vector

  fun flatCoor (row:word,col:word) =
    if row >= col then Word.toInt (Word.div (row*(row+0w1),0w2) + col)
                  else flatCoor (col,row)

  fun getDim v = Word.div(Utils.wordSqrt(0w1+0w8*(Word.fromInt (Vector.length v)))-0w1,0w2)

  fun getDist v (i,j) = Vector.sub (v, flatCoor (i,j))

end

(**
 * Simple pair of vectors holding coordinates.
 *)
structure EuclDist : DISTANCE =
struct

  structure Num = RealNum

  type dist = real vector * real vector

  fun getDim (xs,_) = (Word.fromInt o Vector.length) xs

  fun getDist (xs,ys) (i,j) =
  let
    val dx = Vector.sub (xs, Word.toInt i) - Vector.sub (xs, Word.toInt j)
    val dy = Vector.sub (ys, Word.toInt i) - Vector.sub (ys, Word.toInt j)
  in
    Math.sqrt (dx*dx+dy*dy)
  end

end
