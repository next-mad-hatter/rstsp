(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure PyrNode : TSP_NODE = struct

  open Utils

  type node = word * word

  type hash = node
  fun compare ((l,r), (l',r')) =
    case Word.compare (l,l') of
      EQUAL => Word.compare (r,r')
    | c => c

  fun toString (a,b) = "(" ^ wordToString a ^ "," ^ wordToString b ^ ")"

  fun toHash x = x

  fun toHTHash size (a,b) = a*(size+0w1) + b

  fun normHash hash = Utils.WordPairSet.add (Utils.WordPairSet.empty, hash)

end

structure PyrTour : TSP_TOUR = struct

  open Utils

  type tour = word vector

  fun toString t =
    "<" ^
    (Vector.foldl
      (fn (x,s) => s ^ (if s = "" then "" else " ") ^ wordToString (x+0w1))
      "") t
    ^ ">"

  fun toVector t = t

end

structure PyrGraph : TSP_GRAPH = struct

  structure Node = PyrNode
  structure Tour = PyrTour
  type node = PyrNode.node
  type tour = PyrTour.tour

  val root = (0w0, 0w0)

  datatype descents = TERM of (word * (unit -> tour)) option
                    | DESC of (node * (word -> word) *
                               ((unit -> tour) -> (unit -> tour))) list

  type optional_params = unit

  fun descend size dist () (i,j) =
    case (i > size orelse j > size orelse i=j andalso i <> 0w0,
          i = size-0w1 orelse j = size-0w1) of
      (true,_) => TERM NONE
    | (_,true) => TERM (SOME (dist (i,j), Lazy.susp (fn () => Vector.fromList [i,j])))
    | (_,_) =>
        let
          val k = Word.max (i,j) + 0w1
          val kj = ((k,j),
                    fn d => d + dist (i,k),
                    fn t => Lazy.susp (fn () => Vector.concat [Vector.fromList [i], t ()]))
          val ik = ((i,k),
                    fn d => d + dist (k,j),
                    fn t => Lazy.susp (fn () => Vector.concat [t (), Vector.fromList [j]]))
        in
          DESC [ik, kj]
        end

  fun HTSize size = (size+0w1) * (size+0w1) - 0w1

end
