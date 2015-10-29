(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure SBTour: SB_TOUR = struct

open Utils

local
  structure WordKey = struct
    type ord_key = word
    val compare = Word.compare
  end
  structure WordPairKey = struct
    type ord_key = word * word
    fun compare ((w,s),(w',s')) = let
      val comp = Word.compare (w,w')
    in
      if comp = EQUAL then Word.compare (s,s') else comp
    end
  end
  structure WordVectorKey = struct
    type ord_key = word vector
    val compare = Vector.collate Word.compare
  end
in
  (* FIXME: can we have fast threeMins? *)
  structure WordPairSet: ORD_SET = SplaySetFn(WordPairKey)
  structure WordVectorSet: ORD_SET = SplaySetFn(WordVectorKey)
  structure WordSet: ORD_SET = SplaySetFn(WordKey)
  structure WordMap: ORD_MAP = SplayMapFn(WordKey)
end


(*
 * Ordered map with keys stored outside for faster access
 *)

(* FIXME: is this really faster with keys set? *)
(* TODO: proper polymorphism, i.e. getCount *)
datatype ('a,'b) HashedMap = HMAP of 'a * WordSet.set * 'b WordMap.map
fun getItems (HMAP (x,_,_)) = x
fun getKeys (HMAP (_,x,_)) = x
fun getMap (HMAP (_,_,x)) = x


(*
 * Search tree node:
 *
 * set of ordered intervals, i.e. [a] or [a,b] where a <= b
 *)

type sbnode = (WordPairSet.set, word * word) HashedMap

val empty_node = HMAP (WordPairSet.empty, WordSet.empty, WordMap.empty)
(*
val empty_tour = HMAP (WordVectorSet.empty, WordSet.empty, WordMap.empty)
*)

fun orderInterval (a: word,b) = if a <= b then (a,b) else (b,a)

fun iToList (a,b) = if a = b then [a] else [a,b]

fun insertInterval (node,v) = let
  val v' = orderInterval v
  val vl = iToList v'
  val ints' = WordPairSet.add (getItems node, v')
  val keys' = List.foldl WordSet.add' (getKeys node) vl
  val map' = List.foldl (fn (k,m) => WordMap.insert (m,k,v')) (getMap node) vl
in
  HMAP (ints', keys', map')
end
val insertInterval' = insertInterval o swap

fun removeInterval (node: sbnode, v: word * word) = let
  val v' = orderInterval v
  val ints' = WordPairSet.delete (getItems node, v')
  val vl = iToList v'
  val keys' = foldl (WordSet.delete o swap) (getKeys node) vl
  val map' = foldl (#1 o WordMap.remove o swap) (getMap node) vl
in
  HMAP (ints', keys', map')
end
val removeInterval' = removeInterval o swap


(*
 * Search tree traversal result:
 *
 * set of unordered paths, i.e. [a,...,b] of length >= 2 where a <> b and length > 2 if a = b
 *)

type sbtour = (WordVectorSet.set, word vector) HashedMap

fun pathEnds v =
  if Vector.length v < 2 then raise Fail "No trivial paths allowed." (* [Vector.sub (v,0)] *)
  else (Vector.sub (v,0), Vector.sub (v, (Vector.length v) - 1))

fun pathEnds' v = let
  val (a,b) = pathEnds v
in
  [a,b]
end

fun isConnected t = (WordVectorSet.numItems o getItems) t < 2

fun isComplete t = (WordVectorSet.numItems o getItems) t = 1 andalso let
    val k = valOf (WordSet.find (fn _ => true) (getKeys t))
    val p = valOf (WordMap.find (getMap t, k))
    val (a,b) = pathEnds p
  in
    a = b
  end

fun nodeToString base level node = let
  fun compact (a,b) = if a = b then [a] else [a,b]
  fun int2str i = "(" ^
                  ((String.concatWith ",") o (map (fn x => wordToString (x+base))) o compact) i
                  ^ ")"
in
  wordToString level ^ ": " ^
  ((String.concatWith " ") o (map int2str) o WordPairSet.listItems o getItems) node
end

fun pathToString base v =
  "<" ^
  Vector.foldl (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+base)) "" v
  ^ ">"

fun pathsToString base p = String.concatWith " + "
  (((map (pathToString base)) o WordVectorSet.listItems) p)

fun tourToString' t = (((pathsToString 0w0) o getItems) t)
val tourToString : sbtour -> string = (pathsToString 0w1) o getItems

(* TODO: implement oriented snippets path *)
(* For now: if at all necessary, always reverse second path *)
fun mergePaths (v,w) = let
  val (a,b) = pathEnds v
  val (a',b') = pathEnds w
  val (v',w') = case (a=a', a=b', b=a', b=b') of
                     (true,_,_,_) => (revVector w, v)
                   | (_,true,_,_) => (w, v)
                   | (_,_,true,_) => (v, w)
                   | (_,_,_,true) => (v, revVector w)
                   | _ => raise Fail "Merging incompatible paths."
  (*
  val r = VectorSlice.concat [VectorSlice.full v', VectorSlice.slice (w',1,NONE)]
  val _ = printErr "  << "
  val _ = printErr (pathToString 0w0 v)
  val _ = printErr " + "
  val _ = printErr (pathToString 0w0 w)
  val _ = printErr " = "
  val _ = printErr (pathToString 0w0 r)
  val _ = printErr " >>\n"
  *)
in
  VectorSlice.concat [VectorSlice.full v', VectorSlice.slice (w',1,NONE)]
end

fun singlePath (a,b) = let
  val _ = printErr "Terminal path: <"
  val _ = printErr (wordToString a)
  val _ = printErr ","
  val _ = printErr (wordToString b)
  val _ = printErr ">\n"
  val v = Vector.fromList [a,b]
  val items' = WordVectorSet.add (WordVectorSet.empty, v)
  val keys' = List.foldl WordSet.add' WordSet.empty [a,b]
  val map' = List.foldl (fn (k,m) => WordMap.insert (m,k,v)) WordMap.empty [a,b]
in
  HMAP (items', keys', map')
end

fun insertPath paths v = let
  val _ = printErr "Insert path: "
  val _ = printErr (pathToString 0w0 v)
  val _ = printErr " into {"
  val _ = printErr (tourToString' paths)
  val _ = printErr "}\n"
  val compact = fn l => if length l = 2 andalso hd l = hd (tl l) then tl l else l
  val unique = WordSet.listItems o (foldl WordSet.add' WordSet.empty)
  val stale_paths = ((map valOf) o compact o (List.filter isSome) o
                     (map (fn x => WordMap.find (getMap paths, x)))) (pathEnds' v)
  val stale_keys = (unique o (foldl op@ []) o (map pathEnds')) stale_paths
  val v' = foldl mergePaths v stale_paths
  (*
  val _ = printErr "  deleting: "
  val _ = printErr (((String.concatWith ", ") o (map (pathToString 0w0))) stale_paths)
  val _ = printErr "\n"
  val _ = printErr "  stale keys: "
  val _ = printErr (pathToString 0w0 (Vector.fromList stale_keys))
  val _ = printErr "\n"
  val _ = printErr "  adding: "
  val _ = printErr (pathToString 0w0 v')
  val _ = printErr "\n"
  *)
  val items = foldl (WordVectorSet.delete o swap) (getItems paths) stale_paths
  val items' = WordVectorSet.add (items, v')
  val keys' = foldl (WordSet.delete o swap) (getKeys paths) stale_keys
  val keys'' = foldl WordSet.add' keys' (pathEnds' v')
  val paths' = foldl (#1 o WordMap.remove o swap) (getMap paths) stale_keys
  val paths'' = foldl (fn (k,m) => WordMap.insert (m,k,v')) paths' (pathEnds' v')
in
  HMAP (items', keys'', paths'')
end

local
  fun len dist v =
    (* FIXME: remove *)
    if Vector.length v < 2 then raise Fail "Trivial paths have no length"
    else
      #2 (Vector.foldl
         (fn (q,(p,s)) =>
         (SOME q,if isSome p then s + dist (q,valOf p) else s))
         (NONE,0w0) v)
in
  fun tourLength d t =
    foldl (fn (v,s) => s + len (DistMat.getDist d) v) 0w0 ((WordVectorSet.listItems o getItems) t)
end


(*
 * Tree descent and results' reconstruction.
 *)

local

  fun threeMins node = let
    (* FIXME: can we avoid this easily? *)
    val ks = WordSet.listItems (getKeys node)
    val n = Int.min (length ks, 3)
    val res = List.tabulate (3, fn i => if n > i then SOME (List.nth (ks, i)) else NONE)
    (*
    val _ = printErr "[ Three mins of "
    val _ = printErr (((String.concatWith " ") o
                    (map (fn (x,y) => "(" ^ wordToString x ^ "," ^ wordToString y ^ ")" )) o
                   WordPairSet.listItems o getItems) node)
    val _ = printErr " : "
    val _ = printErr (String.concatWith ", " (map (fn x => if isSome x then wordToString (valOf x) else "none") res))
    val _ = printErr " ]\n"
    *)
  in
    (List.nth (res, 0), List.nth (res, 1), List.nth (res, 2))
  end

  (*
   * Following three return: descendant node, value increase function, construction function
   *)

  fun optAdd node m = (
    insertInterval (node, (m,m)),
    0w0,
    fn x => x
  )

  fun optAppend dist node min1 m = let
    val old = (valOf o WordMap.find) (getMap node, min1)
  in (
    (* NB: intervals are ordered *)
    insertInterval (removeInterval (node, old), (#2 old, m)),
    dist (min1, m),
    fn x => insertPath x (Vector.fromList [min1,m])
    )
  end

  (* NB: min1 < min2 *)
  fun optMerge dist node min1 min2 m = let
    val old = map (fn x => (valOf o WordMap.find) (getMap node, x)) [min1, min2]
    val ab = map #2 old
    val a = hd ab
    val b = (hd o tl) ab
    val _ = printErr "AB: "
    val _ = printErr (wordToString a)
    val _ = printErr ","
    val _ = printErr (wordToString b)
    val _ = printErr "\n"
    val node' = insertInterval (foldl removeInterval' node old, orderInterval (a,b))
  in (
    node',
    dist (min1, m) + dist (m, min2): word,
    fn x => insertPath x (Vector.fromList [min1, m, min2])
    )
  end

in
  fun descentOpts dist node (m:word) = let
    val (m1, m2, m3) = threeMins node
    val o1 = [optAdd node m]
    val o2 = case m1 of
                  SOME m1' => [optAppend dist node m1' m]
                | _ => []
    val o3 = case (m1, m2, m3) of
                  (SOME m1', SOME m2', NONE) =>
                    (*
                    []
                    *)
                    if (valOf o WordMap.find) (getMap node, m1') =
                       (valOf o WordMap.find) (getMap node, m2') then [] else
                         [optMerge dist node m1' m2' m]
                | (SOME m1', SOME m2', SOME m3') => let
                    val m' = if (valOf o WordMap.find) (getMap node, m1') =
                                (valOf o WordMap.find) (getMap node, m2') then m3' else m2'
                  in
                    [optMerge dist node m1' m' m]
                  end
                | _ => []

  in
    o1 @ o2 @ o3
  end
end

(* TODO: not working? *)
local
  structure MapKey =
  struct
    (* FIXME: what would be fast? *)
    type ord_key = word * WordPairSet.set
    fun compare ((w,s),(w',s')) = let
      val comp = Word.compare (w,w')
    in
      if comp = EQUAL then WordPairSet.compare (s,s') else comp
    end
  end
in
  structure MemMap: ORD_MAP = SplayMapFn(MapKey)
end

(* TODO: make pretty +  transparent logdot *)
local
  fun select (a':word,b') (a'':word,b'') = if a' <= a'' then (a',b') else (a'',b'')

  fun search logdot mem (dist: word * word -> word) node m size max_ints = let
    val _ = printErr "Search: ["
    val _ = printErr (nodeToString 0w0 m node)
    val _ = printErr "]\n"
    val memres = MemMap.find (!mem, (m, getItems node))
    (*
    val memres = (SOME (HashTable.lookup mem (getSnippets t))) handle Fail msg => NONE
    *)
  in case memres of
          SOME r => (printErr "Return from memo.\n"; r)
        | NONE => let
      val node_name = "\"" ^ (nodeToString 0w1 m node) ^ "\""
      val node_len = (Word.fromInt o WordPairSet.numItems o getItems) node
    in
      if m >= size then
        if node_len = 0w1 then let
            val p = (hd o WordPairSet.listItems o getItems) node
            val q = singlePath p
            val _ = logdot (node_name ^ " [xlabel = \"{" ^ tourToString q ^ "}\"]; \n")
          in
            SOME (dist p, q)
          end
          else let
            val _ = if max_ints = NONE orelse node_len <= valOf max_ints then
                logdot (node_name ^ " [xlabel = <<font point-size=\"10\">{}</font>>]; \n")
              else ()
            in
              NONE
            end
      else
      if size-m+0w1 < node_len orelse
         isSome max_ints andalso node_len > valOf max_ints then let
           val _ = ()
           (*
           val _ = logdot (node_name ^ " [xlabel = <<font point-size=\"10\">{}</font>>]; \n")
           *)
         in
           NONE
         end
      else
      let
        val opts = descentOpts dist node m
        val _ = app (fn node' =>
          if max_ints = NONE orelse
             (Word.fromInt o WordPairSet.numItems o getItems) node' <= valOf max_ints
          then
            logdot (node_name ^ " -> \"" ^
                    (nodeToString 0w1 (m+0w1) node')
                    ^ "\";\n") else ()) (map #1 opts)
        val sol = foldl (fn ((d_node,d_dist,d_path), old_sol) => let
              val new_sol = search logdot mem dist d_node (m+0w1) size max_ints
            in
              case new_sol of
                   NONE => old_sol
                 | SOME (new_len, new_path) => let
                     val t = (d_dist + new_len, d_path new_path)
                   in case old_sol of
                           NONE => SOME t
                         | SOME s => SOME (select s t)
                   end
            end
          ) NONE opts
        val _ = printErr "Return: ["
        val _ = printErr (nodeToString 0w0 m node)
        val _ = printErr "] => {"
        val _ = printErr (if isSome sol then (tourToString' (#2 (valOf sol))) else "")
        val _ = printErr "}\n"
        val _ = logdot (node_name ^ " [xlabel = \"" ^
                        (if isSome sol then "{" ^ (tourToString (#2 (valOf sol))) ^ "}"
                                       else "<<font color=\"red\">{}</font>>")
                        ^ "\"]; \n")
      in
        mem := MemMap.insert (!mem, (m, getItems node), sol);
        (*
        HashTable.insert mem (getSnippets t, sol);
        *)
        sol
      end
    end
  end

in
  fun balancedSearch max_ints d = let
    val size = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length d)))-0w1,0w2)
    val mem = ref MemMap.empty
    val dotfile = TextIO.openOut "log.dot"
    val logdot: string -> unit = fn s => TextIO.outputSubstr (dotfile, Substring.full s)
    val _ = logdot "digraph Log {\n"
    val _ = logdot "node[shape=box];\n"
    (*
    val mem = HashTable.mkTable
      (HashString.hashString o snippetsToString,op=)
      (0, Fail "not found")
    *)
    val res = (#2 o valOf) (search logdot mem (DistMat.getDist d) empty_node 0w0 size max_ints)
    val _ = logdot "}\n"
    val _ = TextIO.closeOut dotfile;
  in
    res
  end
end

end
