(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure PyrTour: PYR_TOUR = struct

open Utils

type pyrtour = word vector

fun tourToString t =
  "<" ^
  (Vector.foldl (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+0w1)) "") t
  ^
  ">"

fun pathLength dist v =
  #2 (Vector.foldl
     (fn (q,(p,s)) =>
     (SOME q,if isSome p then s + dist (q,valOf p) else s))
     (NONE,0w0) v)
fun tourLength d v = pathLength (DistMat.getDist d) v

local
  structure MemKey =
  struct
    type ord_key = word * word
    fun compare ((w,l),(w',l')) =
      case Word.compare (w,w') of
           EQUAL => Word.compare (l,l')
         | c => c
  end
in
  structure MemMap: ORD_MAP = SplayMapFn(MemKey)
end

(* Shortest pyramidal path from i -> .... n ... -> j,
 * where i is left of n, j is right of n
 *)
fun bestPath mem dist n (i,j) =
let
  val res = MemMap.find (!mem, (i,j))
in
  case res of
       SOME r => r
     | NONE =>
    if i=j andalso i<>0w0 orelse i>n orelse j>n then raise Fail "Hohoho" else
    if i=n orelse j=n then Vector.fromList [i,j] else let
      val k = Word.max (i,j) + 0w1
      val kj = bestPath mem dist n (k,j)
      val ik = bestPath mem dist n (i,k)
      val sol = case dist (i,k) + pathLength dist kj < dist (k,j) + pathLength dist ik of
           true => Vector.concat [Vector.fromList [i], kj]
         | false => Vector.concat [ik, Vector.fromList [j]]
    in
      mem := MemMap.insert (!mem, (i,j), sol);
      sol
  end
end

fun pyrSearch d = let
  val len = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length d)))-0w1,0w2)
  val mem = ref MemMap.empty
in
  bestPath mem (DistMat.getDist d) (len-0w1) (0w0, 0w0)
end

end
