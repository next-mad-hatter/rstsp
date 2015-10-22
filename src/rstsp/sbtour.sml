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
fun isConnected s = (WordVectorSet.numItems o getSnippets) s < 2

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
val insertSnippet' = insertSnippet o swap

fun removeSnippetFrom (t,m) = let
  val v = (valOf o WordMap.find) (getMap t, m)
  val bs = snippetBorders v
  val s' = WordVectorSet.delete (getSnippets t, v)
  val k' = foldl (WordSet.delete o swap) (getKeys t) bs
  val m' = foldl (#1 o WordMap.remove o swap) (getMap t) bs
in
  (SBTOUR (s', k', m'), v)
end
val removeSnippetFrom' = removeSnippetFrom o swap

fun tourFromILL l =
  let
    val vs = map Vector.fromList (map (map Word.fromInt) l)
  in
    List.foldl insertSnippet' empty vs
  end

(* NB: do we want zero-bazed here? *)
fun snippetToString v =
  Vector.foldl (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+0w1)) "" v

fun tourToString t = String.concatWith "; "
  (((map snippetToString) o WordVectorSet.listItems o getSnippets) t)

local
  fun ellen d v =
    if Vector.length v < 2 then raise Fail "Short snippets have no length"
    else let
      val v' = Vector.concat [v,Vector.fromList [Vector.sub(v,0)]]
    in
      #2 (Vector.foldl
         (fn (q,(p,s)) =>
         (SOME q,if isSome p then s+DistMat.getDist d (q,valOf p) else s))
         (NONE,0w0) v')
  end
in
  fun tourLength d t = let
    val s = getSnippets t
  in
    case (WordVectorSet.numItems s) of
         0 =>  raise Fail "Length of empty tours undefined."
       | 1 => ellen d (valOf (WordVectorSet.find (fn _ => true) s))
       | _ =>  raise Fail "Length of snipped tours undefined."
  end
end

local

  (* FIXME: can we avoid this easily? *)
  fun threeMins t = let
    val m = getKeys t
    val n = Int.min (WordSet.numItems m, 3)
    val ks = WordSet.listItems m
  in
    List.take (ks,n)
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
    type ord_key = WordVectorSet.set
    val compare = WordVectorSet.compare
  end
in
  structure MemMap: ORD_MAP = SplayMapFn(MapKey)
end

local
  (* Should we call this insert/add? *)
  fun search mem d t m len = let
    val res = MemMap.find (!mem,getSnippets t)
    (*
    val res = MemMap.find (!mem,(m,getSnippets t))
    *)
  in case res of
          SOME r => r
        | NONE =>
    if m >= len then if isConnected t then SOME t else NONE else
    if len-m+0w1 < (Word.fromInt o WordVectorSet.numItems o getSnippets) t then NONE else
    let
      val ts = map (fn t => search mem d t (m+0w1) len) (balancedOptions t m)
      val ps = ((map (fn t => (tourLength d t, t)) o (map valOf) o (List.filter isSome))) ts
      val sol = #2 (foldl (fn ((l,t),(min,sol)) => if (not o isSome) min orelse valOf min > l then (SOME l,SOME t) else (min,sol)) (NONE,NONE) ps)
    in
      mem := MemMap.insert (!mem,getSnippets t,sol);
      (*
      mem := MemMap.insert (!mem,(m,getSnippets t),sol);
      *)
      sol
    end
  end

in
  fun balancedSearch d = let
    val len = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length d)))-0w1,0w2)
    val mem = ref MemMap.empty
  in
    valOf (search mem d empty 0w0 len)
  end
end

end
