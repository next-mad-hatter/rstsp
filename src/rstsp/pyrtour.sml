(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure PyrTour: PYR_TOUR = struct

open Utils

type pyrtour = word vector

(*
datatype pyrtour = PYRTOUR of word vector * word * word vector

fun getLeft (PYRTOUR (x,_,_)) = x
fun getRight (PYRTOUR (_,_,x)) = x
fun getTop (PYRTOUR (_,x,_)) = x

fun empty len = case len < 0w2 of
                   false => PYRTOUR (Vector.fromList [], len-0w1, Vector.fromList [])
                 |  _ => raise Fail "Tours must have nontrivial length"
fun addLeft t m = case (m > 0w1 andalso m < getTop t) of
                       true => PYRTOUR
                         (Vector.concat [getLeft t, Vector.fromList [m]], getTop t, getRight t)
                     | false => raise Fail "Inserting an out-of-range node"
fun addRight t m = case (m > 0w1 andalso m < getTop t) of
                       true => PYRTOUR
                         (getLeft t, getTop t, Vector.concat [Vector.fromList [m], getRight t])
                     | false => raise Fail "Inserting an out-of-range node"

fun borders t = let
  val l = getLeft t
  val r = getRight t
  val llen = Vector.length l
  val rlen = Vector.length r
in
  [ if llen = 0 then 0w1 else Vector.sub(l, llen-1),
    if rlen = 0 then 0w1 else Vector.sub(r, 0) ]
end

fun tourToVector t =
  Vector.concat [Vector.fromList [0w0], getLeft t, Vector.fromList [getTop t], getRight t]

val tourToString=
  (Vector.foldl (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+0w1)) "") o
  tourToVector
*)

val tourToString=
  (Vector.foldl (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+0w1)) "")

fun pathLength d v =
  #2 (Vector.foldl
     (fn (q,(p,s)) =>
     (SOME q,if isSome p then s+DistMat.getDist d (q,valOf p) else s))
     (NONE,0w0) v)

fun tourLength d t = let
  (* val v = Vector.concat [tourToVector t, Vector.fromList [0w0]] *)
  val v = Vector.concat [t,Vector.fromList [Vector.sub(t,0)]]
in
  pathLength d v
end

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
fun bestPath mem d n (i,j) =
let
  val res = MemMap.find (!mem, (i,j))
in
  case res of
       SOME r => r
     | NONE =>
    if i=j andalso i<>0w0 orelse i>n orelse j>n then raise Fail "Hohoho" else
    if i=n orelse j=n then Vector.fromList [i,j] else let
      val k = Word.max (i,j) + 0w1
      val kj = bestPath mem d n (k,j)
      val ik = bestPath mem d n (i,k)
      val sol = case DistMat.getDist d (i,k) + pathLength d kj < DistMat.getDist d (k,j) + pathLength d ik of
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
  val res = bestPath mem d (len-0w1) (0w0, 0w0)
in
  Vector.fromList (0w0::(Vector.foldl (fn (x,l) => if x = 0w0 then l else x::l) [] res))
end

end
