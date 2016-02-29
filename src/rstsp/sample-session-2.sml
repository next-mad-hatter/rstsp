(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Under SML/NJ, issue
 *   use "./rstsp/rstsp-smlnj.sml";
 * first.
 * Under Poly/ML:
 *   use "./rstsp/rstsp-polyml.sml";
 * .
 *)

open Utils

structure NSrch : SEARCHES = DefaultSearches(IntNum)
datatype tsplib_inst = datatype TsplibReader.tsplib_inst

val node_size = SOME 0w3
val iter_limit = SOME (IntInf.fromInt 3)
val stale_thresh = SOME (IntInf.fromInt 2)
val rotations = SOME 0w3
val options = (iter_limit, stale_thresh, (rotations, 0w0, node_size))
structure Search = NSrch.IterRotSBSearch

structure Dist = Eucl2DNNDist
val inst = TsplibReader.readTSPFile "../../test/data/tsplib/eil51.tsp"
val data = case inst of
             EUCLIDEAN_2D_INSTANCE d => d
           | EUCLIDEAN_2D_CEIL_INSTANCE d => d
           | EXPLICIT_INSTANCE _ => raise Fail "Boom"
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
  val _ = print ("  Solution:  " ^ (Search.tourToString sol) ^ "\n")
  val _ =
    let
      val sol_vec = Search.tourToVector sol
      val len_val = Dist.Num.compare(sol_len, CostCheck.tourCost data sol_vec) = EQUAL
      val sol_val = TSPUtils.validTour size sol_vec
    in
      print ("  Solution valid:  " ^ (if sol_val andalso len_val then "yes" else "NO!") ^ "\n")
    end
  val _ = print ("  Tour cost:  " ^ (IntNum.toString sol_len) ^ "\n")
  val _ = print ("*********************************\n")
in
  ()
end

val _ = TextIO.print;
val _ = main ()
val opt = [1, 22, 8, 26, 31, 28, 3, 36, 35, 20, 2, 29, 21, 16, 50, 34, 30, 9, 49, 10,
           39, 33, 45, 15, 44, 42, 40, 19, 41, 13, 25, 14, 24, 43, 7, 23, 48, 6, 27,
           51, 46,12, 47, 18, 4, 17, 37, 5, 38, 11, 32, 1]
val opt_len = CostCheck.tourCost data ((Vector.fromList o (map (fn x => Word.fromInt (x-1)))) opt)

