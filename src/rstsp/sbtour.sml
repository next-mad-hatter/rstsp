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

fun snippetToString v =
  Vector.foldl (fn (x,s) => s ^ (if s = "" then "" else " ") ^ Word.toString x) "" v

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
        (*
        val _ = print "opt2\n"
        val _ = (print "tour: "; print (tourToString t); print "\n")
        *)
    val v = (valOf o WordMap.find) (getMap t, min1)
        (*
        val _ = (print "v: "; print (snippetToString v); print "\n")
        *)
    val mv = Vector.fromList [m]
    val v' = Vector.concat (if Vector.sub (v,0) = min1 then [mv,v] else [v,mv])
    val s' = WordVectorSet.add (WordVectorSet.delete (getSnippets t, v), v')
    val k' = if Vector.length v' > 2 then WordSet.delete (getKeys t, min1) else getKeys t
    val k'' = WordSet.add (k', m)
    val m' = (#1 o WordMap.remove) (getMap t, min1)
    val m'' = foldl (fn (b,m) => WordMap.insert (m,b,v')) m' (snippetBorders v')
        (*
        val _ = print "ok.\n"
        *)
  in
        (*
        print "new tour: "; print (tourToString (SBTOUR (s',k'',m''))); print "\n";
        print "new keys: "; print (String.concatWith " " (map wordToString (WordSet.listItems k''))); print "\n";
       print "new map: "; print (String.concatWith "; " (((map snippetToString) o WordMap.listItems) m'')); print "\n";
       *)
    SBTOUR (s',k'',m'')
  end

  (* FIXME: speedup *)
  fun glue v1 (m:word) v2 = let
    val v1' = let val b = snippetBorders v1 in
      if length b > 1 andalso hd b < (hd o tl) b then revVector v1 else v1
    end
    val v2' = let val b = snippetBorders v2 in
      if length b > 1 andalso hd b > (hd o tl) b then revVector v2 else v2
    end
  in
    Vector.concat [v1', (Vector.fromList [m]), v2']
  end

  (* FIXME: rewrite with removesnippetfrom? *)
  fun opt3 t min1 min2 m = let
    val v1 = (valOf o WordMap.find) (getMap t, min1)
    val v2 = (valOf o WordMap.find) (getMap t, min2)
    val v' = glue v1 m v2
    val bs = snippetBorders v'
    val s' = foldl (WordVectorSet.delete o swap) (getSnippets t) [v1, v2]
    val s'' = WordVectorSet.add (s', v')
    val k' = foldl (WordSet.delete o swap) (getKeys t) [min1, min2]
    val k'' = foldl WordSet.add' k' bs
    val m' = foldl (#1 o WordMap.remove o swap) (getMap t) [min1, min2]
    val m'' = foldl (fn (b,m) => WordMap.insert (m,b,v')) m' bs
  in
    SBTOUR (s'', k'', m'')
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
  fun search d t m len =
  if m >= len then if isConnected t then SOME t else NONE else
  if len-m+0w1 < (Word.fromInt o WordVectorSet.numItems o getSnippets) t then NONE else
  let
    val ts = map (fn t => search d t (m+0w1) len) (balancedOptions t m)
    val ps = ((map (fn t => (tourLength d t, t)) o (map valOf) o (List.filter isSome))) ts
    val sol = foldl (fn ((l,t),(min,sol)) => if (not o isSome) min orelse valOf min > l then (SOME l,SOME t) else (min,sol)) (NONE,NONE) ps
  in
    #2 sol
  end

in
  fun balancedSearch d = let
    val len = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length d)))-0w1,0w2)
  in
    valOf (search d empty 0w0 len)
  end
end

end
