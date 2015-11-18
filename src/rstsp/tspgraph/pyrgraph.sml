(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Pyramidal Tours Graph.
 *
 * Representation is very straightforward,
 * nodes being word tuples and tours being word vectors.
 *)

structure PyrNode : TSP_NODE = struct

  structure U = Utils
  structure T = TSPTypes

  type node = word * word

  type key = node

  fun compare ((l,r), (l',r')) = case Word.compare (l,l') of
                                   EQUAL => Word.compare (r,r')
                                 | c => c

  fun toString (a,b) = "(" ^ U.wordToString a ^ "," ^ U.wordToString b ^ ")"

  fun toKey x = x

  fun toHash size (a,b) = a*(size+0w1) + b

  fun normKey key = T.WordPairSet.add (T.WordPairSet.empty, key)

end


structure PyrTour : TSP_TOUR = struct

  structure TU = TSPUtils

  type tour = word vector

  val toString = TU.wvToString 0w1

  fun toVector t = t

end


functor PyrGraph(N : NUMERIC) : TSP_GRAPH = struct

  structure Len = N
  structure Node = PyrNode
  structure Tour = PyrTour

  type node = Node.node
  type tour = Tour.tour

  val root = (0w0, 0w0)

  datatype descent = TERM of (Len.num * (unit -> tour)) option
                   | DESC of (node * (Len.num -> Len.num)
                                   * ((unit -> tour) -> (unit -> tour))) list

  type optional_params = unit

  fun descendants size dist _ (i,j) =
    case (i > size orelse j > size orelse i=j andalso i <> 0w0,
          i = size-0w1 orelse j = size-0w1) of
      (true,_) => TERM NONE
    | (_,true) => TERM (SOME (dist (i,j), Lazy.susp (fn () => Vector.fromList [i,j])))
    | (_,_) =>
        let
          val k = Word.max (i,j) + 0w1
          val kj = ((k,j),
                    fn d => Len.+ (d, dist (i,k)),
                    fn t => Lazy.susp (fn () => Vector.concat [Vector.fromList [i], t ()]))
          val ik = ((i,k),
                    fn d => Len.+ (d, dist (k,j)),
                    fn t => Lazy.susp (fn () => Vector.concat [t (), Vector.fromList [j]]))
        in
          DESC [ik, kj]
        end

  fun HTSize (size,_) = (size+0w1) * (size+0w1) - 0w1

end
