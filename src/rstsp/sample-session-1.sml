(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

open Utils

structure NSrch : SEARCHES = DefaultSearches(IntNum)
datatype tsplib_inst = datatype TsplibReader.tsplib_inst

val node_size = SOME 0w3
val iter_limit = SOME (IntInf.fromInt 10)
val stale_thresh = SOME (IntInf.fromInt 2)
val rotations = SOME 0w24
val max_flips = SOME (IntInf.fromInt 20)
val options = (max_flips,
               SOME (IntInf.fromInt 1),
               (iter_limit, stale_thresh, ()),
               (iter_limit, stale_thresh, 0w0, rotations, node_size))
structure Search = NSrch.FlipFlopSearch

structure Dist = NatDist
val inst = TsplibReader.readTSPFile "../../test/data/tsplib/gr17.tsp"
val data = case inst of
             EXPLICIT_INSTANCE v => v
           | EUCLIDEAN_2D_INSTANCE (xs,ys) => raise Fail "not here"
           | EUCLIDEAN_2D_CEIL_INSTANCE (xs,ys) => raise Fail "not here"
structure CostCheck = TSPCostFn(Dist)

fun main () =
let
  val dist = Dist.getDist data
  val size = Dist.getDim data
  val search = Search.search size dist NONE true options
  val (sol', stats) = search ()
  val (sol_len, sol_fn) = valOf sol'
  val sol = sol_fn ()
  val _ = print ("*********************************\n")
  val _ = print ("   Solution:  " ^ (Search.tourToString sol) ^ "\n")
  val _ = case stats of
            NONE => ()
          | SOME (nn, nk, hs) => (
              print (" Node Types:  " ^ (wordToString nk) ^ "\n");
              print (" Store size:  " ^ (wordToString nn) ^ "\n");
              print ("Node hashes:  " ^ (wordToString hs) ^ "\n")
            )
  val _ =
    let
      val sol_vec = Search.tourToVector sol
      val len_val = Dist.Num.compare(sol_len, CostCheck.tourCost data sol_vec) = EQUAL
      val sol_val = TSPUtils.validTour size sol_vec
    in
      print ("    Solution valid:  " ^ (if sol_val andalso len_val then "yes" else "NO!") ^ "\n")
    end
  val _ = print ("  Tour cost:  " ^ (Dist.Num.toString sol_len) ^ "\n")
  val _ = print ("*********************************\n")
in
  ()
end

val _ = TextIO.print;
val _ = main ()

