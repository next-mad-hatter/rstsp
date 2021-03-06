(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Flat vector containing lower triangular part
 * of a matrix, rows concatenated.
 *
 * For now, no wrapover checks are done.
 *)
structure NatDist : DISTANCE =
struct

  structure Num = IntNum

  type dist = IntInf.int vector

  fun getDim v = Word.div(Utils.wordSqrt(0w1+0w8*(Word.fromInt (Vector.length v)))-0w1,0w2)

  fun getDist v (i,j) = Vector.sub (v, TSPUtils.flatCoor (i,j))

end

(**
 * Simple pair of vectors holding floating point coordinates.
 *)
structure Eucl2DDist : DISTANCE =
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

(**
 * Simple pair of vectors holding floating point coordinates.
 *)
structure Eucl2DCeilDist : DISTANCE =
struct

  structure Num = IntNum

  type dist = real vector * real vector

  fun getDim (xs,_) = (Word.fromInt o Vector.length) xs

  fun getDist (xs,ys) (i,j) =
  let
    val dx = Vector.sub (xs, Word.toInt i) - Vector.sub (xs, Word.toInt j)
    val dy = Vector.sub (ys, Word.toInt i) - Vector.sub (ys, Word.toInt j)
  in
    ((Real.toLargeInt IEEEReal.TO_POSINF) o Math.sqrt) (dx*dx+dy*dy)
  end

end

(**
 * Euclidean distance rounded to nearest integer.
 *)
structure Eucl2DNNDist : DISTANCE =
struct

  structure Num = IntNum

  type dist = real vector * real vector

  fun getDim (xs,_) = (Word.fromInt o Vector.length) xs

  fun getDist (xs,ys) (i,j) =
  let
    val dx = Vector.sub (xs, Word.toInt i) - Vector.sub (xs, Word.toInt j)
    val dy = Vector.sub (ys, Word.toInt i) - Vector.sub (ys, Word.toInt j)
  in
    ((Real.toLargeInt IEEEReal.TO_NEAREST) o Math.sqrt) (dx*dx+dy*dy)
  end

end
