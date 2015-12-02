(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Strongly Balanced Tours Graph.
 *
 * FIXME: SBNode and SBTour contain fair amount of HashedMap housekeeping which
 *        should be factored out into a proper structure.
 *        This also keeps us from using TSPNode/TSPTour signatures -- 
 *        since we have to expose their internals to SBGraph.
 *)

(**
 * A SB node consists of
 *   - tree depth (here: also "level") and
 *   - a set of intervals, i.e. {(a_i,b_i) |i in I} where a_i <= b_i.
 *)
structure SBNode =
struct

  open TSPTypes
  open SBUtils
  structure U = Utils

  type intsset = ((WordPairSet.set, word * word) HashedMap)

  type node = word * intsset

  type key = word * WordPairSet.set

  fun eqKeys ((w,s), (w',s')) = w = w' andalso WordPairSet.equal (s,s')

  fun compKeys ((w,s), (w',s')) = case Word.compare (w,w') of
                                    EQUAL => WordPairSet.compare (s,s')
                                  | c => c

  fun toKey (level, ints) = (level, getItems ints)

  local
    fun compact (a,b) = if a = b then [a] else [a,b]
    fun int2str base i =
      "(" ^ ((String.concatWith ",") o (map (fn x => U.wordToString (x+base))) o compact) i ^ ")"
    fun nodeToString base (level, ints) =
      U.wordToString level ^ ": " ^
        ((String.concatWith " ") o (map (int2str base)) o WordPairSet.listItems o getItems) ints
  in
    val toString: node -> string = nodeToString 0w1
  end

  (**
   * A polynomial hash -- fastest so far.
   *)
  fun toHash size (level, ints) =
  let
    val lg = (Real.fromInt o Word.toInt) size;
    val lg' = (Math.ln lg) / (Math.ln 2.0)
    val base = (Word.fromInt o Real.ceil) lg'
    val ps = WordPairSet.listItems ints
    val bs = ListPair.map (fn ((x,y),(x',_)) => (level-x+x',level-y)) (ps, (0w0,0w0)::ps)
    val flat = (foldl (fn ((x,y), l) => y::x::l) []) bs
    val (h,b) = foldl (fn (x,(s,b)) => (s + x*b, b*base)) (0w0,0w1) flat
  in
    level*b + h
  end

  (* A collision free hash --
   * via a map and counting encountered node types.
   *)
  (*
  local
    structure WordPairSetKey = struct
      type ord_key = WordPairSet.set
      val compare = WordPairSet.compare
    end
  in
    structure TypeMap = SplayMapFn(WordPairSetKey)
  end

  fun toHash size =
  let
    fun hasher mem (level, ints) =
      case TypeMap.find (!mem, ints) of
        SOME r => r
      | _ =>
          let
            val t = Word.fromInt (TypeMap.numItems (!mem))
            val _ = mem := TypeMap.insert (!mem, ints, t);
          in
            t*size + level
          end
    val mem = ref TypeMap.empty
  in
    fn args => hasher mem args
  end
  *)

  fun normKey ((level, ints): key) =
      ((WordPairSet.map (fn (a,b) => (level-a-0w2, level-b-0w2))) ints)

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
  val insertInterval' = insertInterval o U.swap

  fun removeInterval (node_ints: intsset, v: word * word) = let
    val v' = orderInterval v
    val ints' = WordPairSet.delete (getItems node_ints, v')
    val vl = intervalToList v'
    val keys' = foldl (WordSet.delete o U.swap) (getKeys node_ints) vl
    val map' = foldl (#1 o WordMap.remove o U.swap) (getMap node_ints) vl
  in
    HMAP (ints', keys', map')
  end
  val removeInterval' : (word * word) * intsset -> intsset = removeInterval o U.swap

end


(*
 * A SB tour is a set of paths, i.e.
 * {[a_i, c_i_1, ...,, c_i_k_i, b_i] | i in I} of length >= 2
 * where a_i <> b_i and path length > 2 where a_i = b_i.
 *)
structure SBTour =
struct

  open TSPTypes
  open SBUtils
  structure U = Utils
  structure TU = TSPUtils

  type tour = (WordVectorSet.set, word vector) HashedMap

  local
    fun pathsToString base p = String.concatWith " + "
      (((map (TU.wvToString base)) o WordVectorSet.listItems) p)
  in
    val toString : tour -> string = (pathsToString 0w1) o getItems
  end

  fun numItems paths = (WordVectorSet.numItems o getItems) paths

  fun toVector paths =
    case numItems paths <> 1 of
      true => raise Fail "Cannot export incomplete tours."
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
    val items = foldl (WordVectorSet.delete o U.swap) (getItems paths) stale_paths
    val items' = WordVectorSet.add (items, v')
    val keys' = foldl (WordSet.delete o U.swap) (getKeys paths) stale_keys
    val keys'' = foldl WordSet.add' keys' (pathEnds' v')
    val paths' = foldl (#1 o WordMap.remove o U.swap) (getMap paths) stale_keys
    val paths'' = foldl (fn (k,m) => WordMap.insert (m,k,v')) paths' (pathEnds' v')
  in
    HMAP (items', keys'', paths'')
  end

end


functor SBGraph(N : NUMERIC) : TSP_GRAPH =
struct

  open TSPTypes
  open SBUtils
  structure U = Utils

  structure Node = SBNode
  structure Tour = SBTour
  structure Len = N

  type node = SBNode.node
  type tour = SBTour.tour

  val root = (0w0, HMAP (WordPairSet.empty, WordSet.empty, WordMap.empty))

  datatype descent = TERM of (Len.num * (unit -> tour)) option
                   | DESC of (node * (Len.num -> Len.num)
                                   * ((unit -> tour) -> (unit -> tour))) list

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
    fn d => d,
    fn x => x
  )

  fun optAppend dist (level, ints) min1 = let
    val old = (valOf o WordMap.find) (getMap ints, min1)
  in (
    (* NB: intervals are sorted *)
    (level+0w1, Node.insertInterval (Node.removeInterval (ints, old), (#2 old, level))),
    fn d => Len.+ (d, dist (min1, level)),
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
    fn d => Len.+(d, Len.+(dist (min1,level), dist (level,min2))),
    fn t => Lazy.susp (fn () => Tour.insertPath (Vector.fromList [min1, level, min2]) (t ()))
    )
  end

  fun descentOpts size dist max_node_size node =
  let
    val (level, ints) = node
    val node_len = Node.numItems node
    val (m1, m2, m3) = threeMins ints
    val o1 = case (
                isSome max_node_size andalso Node.numItems node = valOf max_node_size
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

  fun descendants size dist max_node_size node =
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
    | _ => DESC (descentOpts size dist max_node_size node)
  end

  (* FIXME: use final tree width as opposed to unique area as growth factor *)
  fun HTSize (size, opts) =
    case opts of
      NONE => size * 0w121
    | SOME m => (size+0w1) * U.power(0w11,m)

end
