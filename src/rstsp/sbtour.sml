(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure SBTour: SB_TOUR = struct

open Utils

local
  structure WordKey =
  struct
    type ord_key = word
    val compare = Word.compare;
  end
  structure WordVectorKey =
  struct
    type ord_key = word vector
    val compare = Vector.collate Word.compare;
  end
in
  structure WordVectorSet: ORD_SET = SplaySetFn(WordVectorKey)
  (* FIXME: can we have fast threeMins? *)
  structure WordSet: ORD_SET = SplaySetFn(WordKey)
  structure WordMap: ORD_MAP = SplayMapFn(WordKey)
end

datatype sbtour = SBTOUR of WordVectorSet.set * WordSet.set * word vector WordMap.map

fun getSnippets (SBTOUR (x,_,_)) = x
fun getKeys (SBTOUR (_,x,_)) = x
fun getMap (SBTOUR (_,_,x)) = x

val empty = SBTOUR (WordVectorSet.empty, WordSet.empty, WordMap.empty)
fun connected s = (WordVectorSet.numItems o getSnippets) s < 2

fun snippetBorders v =
  if Vector.length v = 1 then [Vector.sub (v,0)]
  else [Vector.sub (v,0), Vector.sub (v, (Vector.length v) - 1)]

fun insertSnippet (t,v) =
  if Vector.length v = 0 then raise Fail "No empty snippets allowed."
  else let
    val newkeys = snippetBorders v
    val snippets = WordVectorSet.add (getSnippets t, v)
    val keys = List.foldl WordSet.add' (getKeys t) newkeys
    val map = List.foldl (fn (k,m) => WordMap.insert (m,k,v)) (getMap t) newkeys
  in
    SBTOUR (snippets, keys, map)
  end
fun insertSnippet' (v,t) = insertSnippet (t,v)

fun fromILL l =
  let
    val vs = map Vector.fromList (map (map Word.fromInt) l)
  in
    List.foldl insertSnippet' empty vs
  end

local
  fun ellen d v =
    if Vector.length v < 2 then 0w0
    else #2 (Vector.foldl
             (fn (q,(p,s)) => (SOME q,if isSome p then s+DistMat.getDist d (q,valOf p) else s))
                  (NONE,0w0) v)
in
  fun tourLength d t = let
    val s = getSnippets t
  in
    if (WordVectorSet.numItems s) = 1 then ellen d (valOf (WordVectorSet.find (fn _ => true) s))
    else raise Fail "Length of snipped tours undefined."
  end
end

fun threeMins t = let
  val m = getKeys t
  val n = Int.min (WordSet.numItems m, 3)
  val ks = WordSet.listItems m
in
  List.take (ks,n)
end

end
