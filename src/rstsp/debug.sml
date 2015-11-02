(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

open Utils

(*
 * NB: (HACK) SML/NJ has some problem with CML and readDistFile (?!),
 * so we have to call it prior to loading CML -- see rstsp.smlnj.
 *)
val distance = (valOf o DistMat.readDistFile) "../../test/data/misc/dantzig42_d.txt";

(*
structure Search : TSP_SEARCH = SimpleSearchFn(PyrGraph)
val options = ()
*)
structure Search : TSP_SEARCH = SimpleSearchFn(SBGraph)
val options = SOME 0w3
(*
structure Search : TSP_SEARCH = CMLSearchFn(SBGraph)
val options = SOME 0w4
*)

fun main () =
let
  val size = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length distance)))-0w1,0w2)
  val dist = DistMat.getDist distance
  val search = Search.search size dist NONE options
  val timer = Timer.startCPUTimer ()
  val sol = valOf (search ())
  val time_sys = (#sys o Timer.checkCPUTimer) timer
  val time_usr = (#usr o Timer.checkCPUTimer) timer
  val sol_vec = Search.Tour.toVector sol
  val sol_str = Search.Tour.toString sol
  val sol_len = tourLength dist sol_vec
  val sol_val = validTour size sol_vec
  val _ = print ("*********************************\n")
  val _ = print ("  Solution:  " ^ sol_str ^ "\n")
  val _ = print ("     Valid:  " ^ (if sol_val then "yes" else "NO!") ^ "\n")
  val _ = print ("    Length:  " ^ (wordToString sol_len) ^ "\n")
  val _ = print ("       Sys:  " ^ (IntInf.toString o Time.toMilliseconds ) time_sys ^ "\n")
  val _ = print ("       Usr:  " ^ (IntInf.toString o Time.toMilliseconds ) time_usr ^ "\n")
  val _ = print ("*********************************\n")
in
  ()
end

val _ = main ()
(*
val _ = RunCML.doit (main (); RunCML.shutdown OS.Process.success, NONE)
*)

