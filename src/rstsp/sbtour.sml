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
in
  (* FIXME: can we have fast threeMins? *)
  structure WordSet: ORD_SET = SplaySetFn(WordKey)
  structure WordMap: ORD_MAP = SplayMapFn(WordKey)
end


(*
 * Ordered map with keys stored outside for faster access
 *)

(* FIXME: is this really faster with keys set? *)
datatype 'a HashedMap = HMAP of WordSet.set * 'a WordMap.map
fun getKeys (HMAP (x,_)) = x
fun getMap (HMAP (_,x)) = x


(*
 * Search tree node:
 *
 * set of ordered intervals, i.e. [a] or [a,b] where a <= b
 *)

type sbnode = word list HashedMap

val empty = HMAP (WordSet.empty, WordMap.empty)

fun orderInterval [x]:word list = [x]
  | orderInterval (a::b::[]) = if a > b then [b,a] else [a,b]
  | orderInterval _ = raise Fail "Ordering empty interval."

fun insertInterval (node,v) =
  if v = [] then raise Fail "No empty intervals allowed."
  else let
    val v' = orderInterval v
    val keys = List.foldl WordSet.add' (getKeys node) v'
    val ints = List.foldl (fn (k,m) => WordMap.insert (m,k,v')) (getMap node) v'
  in
    HMAP (keys, ints)
  end
val insertInterval' = insertInterval o swap

fun removeInterval (node: word list HashedMap,v: word list) = let
  (* FIXME: remove for speed *)
  val _ = let
    val v' = orderInterval v
  in
    if map (fn x => WordMap.find (getMap node, x)) v = [SOME v', SOME v'] then ()
    else raise Fail "Interval not found"
  end
  val keys = foldl (WordSet.delete o swap) (getKeys node) v
  val ints = foldl (#1 o WordMap.remove o swap) (getMap node) v
in
  HMAP (keys, ints)
end
val removeInterval' = removeInterval o swap


(*
 * Search tree traversal result:
 *
 * set of unordered paths, i.e. [a,...,b] of length >= 2 where a <> b and length > 2 if a = b
 *)

type sbtour = word vector HashedMap

fun pathEnds v =
  if Vector.length v < 2 then raise Fail "No trivial paths allowed." (* [Vector.sub (v,0)] *)
  else (Vector.sub (v,0), Vector.sub (v, (Vector.length v) - 1))

fun pathEnds' v = let
  val (a,b) = pathEnds v
in
  [a,b]
end

fun isConnected t = WordMap.numItems (getMap t) < 2

fun isComplete t = WordMap.numItems (getMap t) = 1 andalso let
    val k = valOf (WordSet.find (fn _ => true) (getKeys t))
    val p = valOf (WordMap.find (getMap t, k))
    val (a,b) = pathEnds p
  in
    a = b
  end

(* FIXME: implement oriented snippets path *)
(* For now: if at all necessary, always reverse first path *)
fun mergePaths (v,w) = let
  val (a,b) = pathEnds v
  val (a',b') = pathEnds w
  val (v',w') = case (a=a', a=b', b=a', b=b') of
                     (true,_,_,_) => (revVector v, w)
                   | (_,true,_,_) => (w, v)
                   | (_,_,true,_) => (v, w)
                   | (_,_,_,true) => (w, revVector v)
                   | _ => raise Fail "Merging incompatible paths."
in
  VectorSlice.concat [VectorSlice.full v', VectorSlice.slice (w',1,NONE)]
end

fun singlePath (a,b) = let
  val v = Vector.fromList [a,b]
  val keys = List.foldl WordSet.add' WordSet.empty [a,b]
  val paths = List.foldl (fn (k,m) => WordMap.insert (m,k,v)) WordMap.empty [a,b]
in
  HMAP (keys, paths)
end

fun appendPath paths (a,m) = let
  val p = valOf (WordMap.find (getMap paths, a))
  val v' = mergePaths (Vector.fromList [m,a], p)
  val keys = WordSet.add (WordSet.delete (getKeys paths, a), m)
  val paths' = WordMap.insert (#1 (WordMap.remove (getMap paths, a)), m, v')
in
  HMAP (keys, paths')
end

fun insertPath paths (a,m,b) = let
  val v = Vector.fromList [a,m,b]
  val p = WordMap.find (getMap paths, a)
  val q = WordMap.find (getMap paths, b)
  val v' = case (p,q) of
                (NONE, NONE) => v
              | (SOME p', NONE) => mergePaths (v, p')
              | (NONE, SOME q') => mergePaths (v, q')
              | (SOME p', SOME q') => if p'= q' then raise Fail "Mergins single path."
                                                else mergePaths (p', mergePaths (v, q'))
  val stale_keys = case (p,q) of
                (NONE, NONE) => []
              | (SOME p', NONE) => [a]
              | (NONE, SOME q') => [b]
              | (SOME p', SOME q') => [a,b]
  val keys' = foldl WordSet.add' (foldl (WordSet.delete o swap) (getKeys paths) stale_keys) [a,b]
  val paths' = foldl (#1 o WordMap.remove o swap) (getMap paths) stale_keys
  val paths'' = foldl (fn (k,m) => WordMap.insert (m,k,v')) paths' [a,b]
in
  HMAP (keys', paths'')
end

(* NB: do we want zero-bazed here? *)
fun pathToString v =
  Vector.foldl (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+0w1)) "" v

fun tourToString t = String.concatWith "; "
  (((map pathToString) o WordMap.listItems) t)

local
  fun len dist v =
    (* FIXME: remove *)
    if Vector.length v < 2 then raise Fail "Trivial paths have no length"
    else
      #2 (Vector.foldl
         (fn (q,(p,s)) =>
         (SOME q,if isSome p then s+DistMat.getDist d (q,valOf p) else s))
         (NONE,0w0) v)
in
  fun tourLength d t =
    foldl (fn (v,s) => s + len (DistMat.getDist d) v) 0w0 ((WordMap.listItems o getMap) t)
end


(*
 *
 * Tree descent and results' reconstruction.
 *
 *)

local

  (* FIXME: can we avoid this easily? *)
  fun threeMins t = let
    val ks = getKeys t
    val n = Int.min (WordSet.numItems ks, 3)
    val ms = WordSet.listItems ks
  in
    List.take (ms,n)
  end

  (* FIXME: rewrite with removesnippetfrom? *)
  fun opt2 t min1 m = let
    val v = (valOf o WordMap.find) (getMap t, min1)
    val mv = Vector.fromList [m]
    val v' = Vector.concat [revVector v,mv]
    val s' = WordVectorSet.add (WordVectorSet.delete (getSnippets t, v), v')
    val k' = if Vector.length v' > 2 then WordSet.delete (getKeys t, min1) else getKeys t
    val k'' = WordSet.add (k', m)
    val m' = (#1 o WordMap.remove) (getMap t, min1)
    val m'' = foldl (fn (b,m) => WordMap.insert (m,b,v')) m' (snippetBorders v')
  in
    SBTOUR (s',k'',m'')
  end

  fun glue v1 (m:word) v2 = let
    val b1 = Vector.sub (v1,Vector.length v1 - 1)
    val b2 = Vector.sub (v2,Vector.length v2 - 1)
    val (v1',v2') = if b1 < b2 then (v1,v2) else (v2,v1)
  in
    Vector.concat [revVector v1', (Vector.fromList [m]), v2']
  end

  fun opt3 t min1 min2 m = let
    val (t',v1) = removeSnippetFrom (t, min1)
    val (t'',v2) = removeSnippetFrom (t', min2)
    val v' = glue v1 m v2
  in
    insertSnippet (t'',v')
  end

in
  fun balancedOptions t m = let
    val mins = threeMins t
    val o1 = [insertSnippet (t, Vector.fromList [m])]
    val o2 = if length mins > 0 then [opt2 t (hd mins) m] else []
    val o3 = if length mins > 2 then
      let
        val m1::m2::m3::_ = mins
        val m' = if (valOf o WordMap.find) (getMap t,m1) =
                    (valOf o WordMap.find) (getMap t,m2) then m3 else m2
      in
        [opt3 t m1 m' m]
      end
      else []
  in
    o1 @ o2 @ o3
  end
end

local
  structure MapKey =
  struct
    (*
    type ord_key = word * WordVectorSet.set
    fun compare ((w,s),(w',s')) = let
      val comp = Word.compare (w,w')
    in
      if comp = EQUAL then WordVectorSet.compare (s,s') else comp
    end
    *)
    (*
    type ord_key = WordVectorSet.set
    val compare = WordVectorSet.compare
    *)
    (*
    type ord_key = word vector vector
    val compare = Vector.collate (Vector.collate Word.compare)
    *)
    type ord_key = word vector list
    val compare = List.collate (Vector.collate Word.compare)
    (* WRONG :)
    type ord_key = word * word list list
    val comp = List.collate (List.collate Word.compare)
    fun compare ((w,l),(w',l')) =
      case Word.compare (w,w') of
           EQUAL => comp (l,l')
         | c => c
    *)
  end
in
  structure MemMap: ORD_MAP = SplayMapFn(MapKey)
end

local
  (* Should we call this insert/add? *)
  fun search mem d t m len max = let
    (* WRONG :)
    val res = MemMap.find (!mem,
      (m,((List.filter (fn l => length l > 1)) o (map snippetBorders) o WordVectorSet.listItems o getSnippets) t))
    *)
    val res = if isSome max then MemMap.find (!mem,WordVectorSet.listItems (getSnippets t)) else NONE
    (*
    val res = MemMap.find (!mem,(Vector.fromList o WordVectorSet.listItems o getSnippets) t)
    val res = MemMap.find (!mem,getSnippets t)
    val res = MemMap.find (!mem,(m,getSnippets t))
    *)
    (*
    val res = (SOME (HashTable.lookup mem (getSnippets t))) handle Fail msg => NONE
    *)
    val lent = (Word.fromInt o WordVectorSet.numItems o getSnippets) t
  in case res of
          SOME r => r
        | NONE =>
    if m >= len then if isConnected t then SOME t else NONE else
    if len-m+0w1 < lent orelse isSome max andalso lent > valOf max then NONE else
    let
      val ts = map (fn t => search mem d t (m+0w1) len max) (balancedOptions t m)
      val ps = ((map (fn t => (tourLength d t, t)) o (map valOf) o (List.filter isSome))) ts
      val sol = #2 (foldl (fn ((l,t),(min,sol)) => if (not o isSome) min orelse valOf min > l then (SOME l,SOME t) else (min,sol)) (NONE,NONE) ps)
    in
      (* WRONG :)
      mem := MemMap.insert (!mem,
        (m,((List.filter (fn l => length l > 1)) o (map snippetBorders) o WordVectorSet.listItems o getSnippets) t), sol);
      *)
      if isSome max then
        mem := MemMap.insert (!mem,WordVectorSet.listItems (getSnippets t),sol)
      (*
      mem := MemMap.insert (!mem,(Vector.fromList o WordVectorSet.listItems o getSnippets) t,sol);
      mem := MemMap.insert (!mem,getSnippets t,sol);
      mem := MemMap.insert (!mem,(m,getSnippets t),sol);
      *)
      (*
      HashTable.insert mem (getSnippets t, sol);
      *)
      else ();
      sol
    end
  end

in
  fun balancedSearch max d = let
    val len = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length d)))-0w1,0w2)
    val mem = ref MemMap.empty
    (*
    val mem = HashTable.mkTable
      (HashString.hashString o snippetsToString,op=)
      (0, Fail "not found")
    *)
  in
    valOf (search mem d empty 0w0 len max)
  end
end

end
