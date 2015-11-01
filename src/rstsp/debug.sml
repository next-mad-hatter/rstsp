(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

use "rstsp-smlnj.sml";

open Utils

val d = (valOf o DistMat.readDistFile) "../../test/data/small/small.0"
val size = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length d)))-0w1,0w2)
val dist = DistMat.getDist d

(*
structure Search : TSP_SEARCH = TSPSearchFn(PyrGraph)
val search = Search.search size dist ()
*)
val max_int = SOME 0w2
structure Search : TSP_SEARCH = TSPSearchFn(SBGraph)
val search = Search.search size dist max_int

val timer = Timer.startCPUTimer ()
val sol = valOf (search ())
val time_sys = (#sys o Timer.checkCPUTimer) timer
val time_user = (#usr o Timer.checkCPUTimer) timer
val sol_vec = Search.Tour.toVector sol
val sol_str = Search.Tour.toString sol
val sol_len = tourLength dist sol_vec
val sol_val = validTour size sol_vec

