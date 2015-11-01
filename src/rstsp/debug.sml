(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

use "rstsp-smlnj.sml";

open Utils

(*
structure Search : TSP_SEARCH = TSPSimpleSearchFn(PyrGraph)
val options = ()
*)
(*
structure Search : TSP_SEARCH = TSPSimpleSearchFn(SBGraph)
val options = SOME 0w3
*)
structure Search : TSP_SEARCH = TSPAsyncSearchFn(SBGraph)
val options = SOME 0w3

fun main () =
let
  val size = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length distance)))-0w1,0w2)
  val dist = DistMat.getDist distance
  val search = Search.search size dist NONE options
  val timer = Timer.startCPUTimer ()
  val sol = valOf (search ())
  val time_sys = (#sys o Timer.checkCPUTimer) timer
  val time_user = (#usr o Timer.checkCPUTimer) timer
  val sol_vec = Search.Tour.toVector sol
  val sol_str = Search.Tour.toString sol
  val sol_len = tourLength dist sol_vec
  val sol_val = validTour size sol_vec
  val _ = print ("*********************************\n")
  val _ = print ("  Solution:  " ^ sol_str ^ "\n")
  val _ = print ("     Valid:  " ^ (if sol_val then "yes" else "NO!") ^ "\n")
  val _ = print ("    Length:  " ^ (wordToString sol_len) ^ "\n")
  val _ = print ("*********************************\n")
in
  RunCML.shutdown OS.Process.success;
  ()
end

val _ = RunCML.doit (main, NONE)

