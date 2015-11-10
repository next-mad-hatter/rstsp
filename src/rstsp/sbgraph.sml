(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(*
 * Search tree node:
 *
 * depth & set of intervals, i.e. (a,b) where a <= b
 *)
structure SBNode = struct

  open Utils
  open SBUtils

  type intsset = ((WordPairSet.set, word * word) HashedMap)
  type node = word * intsset

  type hash = word * WordPairSet.set
  fun compare ((w,s), (w',s')) =
    case Word.compare (w,w') of
      EQUAL => WordPairSet.compare (s,s')
    | c => c

  fun toHash (level, ints) = (level, getItems ints)

  local
    fun compact (a,b) = if a = b then [a] else [a,b]
    fun int2str base i =
      "(" ^ ((String.concatWith ",") o (map (fn x => wordToString (x+base))) o compact) i ^ ")"
    fun nodeToString base (level, ints) =
      wordToString level ^ ": " ^
        ((String.concatWith " ") o (map (int2str base)) o WordPairSet.listItems o getItems) ints
  in
    val toString: node -> string = nodeToString 0w1

    (* TODO *)
    fun toHTHash _ (level, ints) =
      HashString.hashString (
        wordToString level ^ ": " ^
          ((String.concatWith " ") o (map (int2str 0w0)) o WordPairSet.listItems) ints
      )

  end


  fun getInts ((_, ints): node): intsset = ints
  fun getLevel ((level, _): node): word = level
  fun numItems (_, ints) = (Word.fromInt o WordPairSet.numItems o getItems) ints

  fun insertInterval (node_ints, v) = let
    val v' = orderInterval v
    val vl = intervalToList v'
    val ints' = WordPairSet.add (getItems node_ints, v')
    val keys' = List.foldl WordSet.add' (getKeys node_ints) vl
    val map' = List.foldl (fn (k,m) => WordMap.insert (m,k,v')) (getMap node_ints) vl
  in
    HMAP (ints', keys', map')
  end
  val insertInterval' = insertInterval o swap

  fun removeInterval (node_ints: intsset, v: word * word) = let
    val v' = orderInterval v
    val ints' = WordPairSet.delete (getItems node_ints, v')
    val vl = intervalToList v'
    val keys' = foldl (WordSet.delete o swap) (getKeys node_ints) vl
    val map' = foldl (#1 o WordMap.remove o swap) (getMap node_ints) vl
  in
    HMAP (ints', keys', map')
  end
  val removeInterval' : (word * word) * intsset -> intsset = removeInterval o swap

  fun normHash ((level, ints): hash) =
      ((WordPairSet.map (fn (a,b) => (level-a-0w2, level-b-0w2))) ints)

end


(*
 * Search tree traversal result:
 *
 * set of paths, i.e. [a,...,b] of length >= 2 where a <> b and length > 2 if a = b
 *)
structure SBTour = struct

  open Utils
  open SBUtils

  type tour = (WordVectorSet.set, word vector) HashedMap
  type lazy_tour = unit -> tour

  local
    fun pathToString base v =
      "<" ^
      Vector.foldl (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+base)) "" v
      ^ ">"
    fun pathsToString base p = String.concatWith " + "
      (((map (pathToString base)) o WordVectorSet.listItems) p)
  in
    val toString : tour -> string = (pathsToString 0w1) o getItems
  end

  fun numItems paths = (WordVectorSet.numItems o getItems) paths

  fun toVector paths =
    case numItems paths <> 1 of
      true => raise Fail "Cannot export invalid tours."
    | _ => valOf (WordVectorSet.find (fn _ => true) (getItems paths))

  fun singlePath (a,b) = let
    val v = Vector.fromList [a,b]
    val items' = WordVectorSet.add (WordVectorSet.empty, v)
    val keys' = List.foldl WordSet.add' WordSet.empty [a,b]
    val map' = List.foldl (fn (k,m) => WordMap.insert (m,k,v)) WordMap.empty [a,b]
  in
    HMAP (items', keys', map')
  end

  fun insertPath v paths = let
    val compact = fn l => if length l = 2 andalso hd l = hd (tl l) then tl l else l
    val unique = WordSet.listItems o (foldl WordSet.add' WordSet.empty)
    val stale_paths = ((map valOf) o compact o (List.filter isSome) o
                       (map (fn x => WordMap.find (getMap paths, x)))) (pathEnds' v)
    val stale_keys = (unique o (foldl op@ []) o (map pathEnds')) stale_paths
    val v' = foldl mergePaths v stale_paths
    val items = foldl (WordVectorSet.delete o swap) (getItems paths) stale_paths
    val items' = WordVectorSet.add (items, v')
    val keys' = foldl (WordSet.delete o swap) (getKeys paths) stale_keys
    val keys'' = foldl WordSet.add' keys' (pathEnds' v')
    val paths' = foldl (#1 o WordMap.remove o swap) (getMap paths) stale_keys
    val paths'' = foldl (fn (k,m) => WordMap.insert (m,k,v')) paths' (pathEnds' v')
  in
    HMAP (items', keys'', paths'')
  end

end


(*
 * Tree descent and results' reconstruction.
 *)
structure SBGraph : TSP_GRAPH = struct

  open Utils
  open SBUtils

  structure Node = SBNode
  structure Tour = SBTour
  type node = SBNode.node
  type tour = SBTour.tour

  val root = (0w0, HMAP (WordPairSet.empty, WordSet.empty, WordMap.empty))

  datatype descents = TERM of (word * (unit -> tour)) option
                    | DESC of (node * (word -> word) *
                               ((unit -> tour) -> (unit -> tour))) list


  fun threeMins ints = let
    (* FIXME: can we avoid this easily? *)
    val ks = WordSet.listItems (getKeys ints)
    val n = Int.min (length ks, 3)
    val res = List.tabulate (3, fn i => if n > i then SOME (List.nth (ks, i)) else NONE)
  in
    (List.nth (res, 0), List.nth (res, 1), List.nth (res, 2))
  end

  fun optAdd (level, ints) = (
    (level+0w1, Node.insertInterval (ints, (level,level))),
    fn (d:word) => d,
    fn x => x
  )

  fun optAppend dist (level, ints) min1 = let
    val old = (valOf o WordMap.find) (getMap ints, min1)
  in (
    (* NB: intervals are sorted *)
    (level+0w1, Node.insertInterval (Node.removeInterval (ints, old), (#2 old, level))),
    fn (d:word) => d + dist (min1, level),
    fn t => Lazy.susp (fn () => Tour.insertPath (Vector.fromList [min1,level]) (t ()))
    )
  end

  (* NB: min1 < min2 *)
  fun optMerge dist (level, ints) min1 min2 = let
    val old = map (fn x => (valOf o WordMap.find) (getMap ints, x)) [min1, min2]
    val ab = map #2 old
    val a = hd ab
    val b = (hd o tl) ab
    val ints' = Node.insertInterval (foldl Node.removeInterval' ints old, orderInterval (a,b))
  in (
    (level+0w1, ints'),
    fn d => d + dist (min1, level) + dist (level, min2): word,
    fn t => Lazy.susp (fn () => Tour.insertPath (Vector.fromList [min1, level, min2]) (t ()))
    )
  end

  fun descentOpts size dist max_ints node =
  let
    val (level, ints) = node
    val node_len = Node.numItems node
    val (m1, m2, m3) = threeMins ints
    val o1 = case (
                isSome max_ints andalso Node.numItems node = valOf max_ints
                orelse node_len > size-level-0w1
              ) of
               true => []
             | _ => [optAdd node]
    val o2 = case (
                node_len > size-level,
                m1
               ) of
               (false, SOME m1') => [optAppend dist node m1']
             | _ => []
    val o3 = case (m1, m2, m3) of
               (SOME m1', SOME m2', NONE) =>
                 if (valOf o WordMap.find) (getMap ints, m1') =
                    (valOf o WordMap.find) (getMap ints, m2') then [] else
                      [optMerge dist node m1' m2']
             | (SOME m1', SOME m2', SOME m3') => let
                 val m' = if (valOf o WordMap.find) (getMap ints, m1') =
                             (valOf o WordMap.find) (getMap ints, m2') then m3' else m2'
               in
                 [optMerge dist node m1' m']
               end
             | _ => []

  in
    o1 @ o2 @ o3
  end

  type optional_params = word option

  fun descend size dist max_ints node =
  let
    val (level, ints) = node
    val node_len = Node.numItems node
  in
    case (node_len = 0w1, level >= size) of
      (true,true) =>
        let
          val p = (hd o WordPairSet.listItems o getItems) ints
          val q = Tour.singlePath p
        in
          TERM (SOME (dist p, Lazy.susp (fn () => q)))
        end
    | (_,true) => TERM NONE
    | _ => DESC (descentOpts size dist max_ints node)
  end

  fun HTSize size = (size+0w1) * 0w121

end
