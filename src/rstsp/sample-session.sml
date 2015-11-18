(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

open Utils

structure NSrch : SEARCHES = DefaultSearches(WordNum)
structure RSrch : SEARCHES = DefaultSearches(RealNum)

val inst = TsplibReader.readTSPFile "../../test/data/misc/gr17_d.txt"

val node_size = SOME 0w3
val iter_limit = SOME (IntInf.fromInt 10)
val stale_thresh = SOME (IntInf.fromInt 2)
val rotations = NONE

(*
val options = ()
structure Search = PyrSearch
*)
(*
val options = node_size
structure Search = SBSearch
*)
(*
val options = (iter_limit, stale_thresh, ())
structure Search = LocalPyrSearch
*)
(*
val options = (iter_limit, stale_thresh, node_size)
structure Search = LocalSBSearch
*)
(*
val options = (rotations, (iter_limit, stale_thresh, node_size))
structure Search = RotLocalSBSearch
*)
(*
val options = (rotations, (iter_limit, stale_thresh, ()))
structure Search = RotLocalPyrSearch
*)
(*
val options = (iter_limit, stale_thresh, (rotations, (node_size)))
structure Search = LocalRotSBSearch
*)
(*
*)
val options = (iter_limit, stale_thresh, (rotations, ()))
structure Search = NSrch.RotPyrSearch

fun main () =
let
  val size = NatDist.getDim data
  val dist = NatDist.getDist data
  val search = Search.search size dist NONE true options
  val timer = Timer.startCPUTimer ()
  val (sol', stats) = search ()
  val sol = ((#2 o valOf) sol') ()
  val time_sys = (#sys o Timer.checkCPUTimer) timer
  val time_usr = (#usr o Timer.checkCPUTimer) timer
  val sol_vec = Search.toVector sol
  val sol_str = Search.toString sol
  val sol_len = tourLength dist sol_vec
  val sol_val = validTour size sol_vec
  val _ = print ("*********************************\n")
  val _ = case stats of
            NONE => ()
          | SOME (nn, nk, hs) => (
              print (" Node Types:  " ^ (wordToString nk) ^ "\n");
              print (" Store size:  " ^ (wordToString nn) ^ "\n");
              print ("Node hashes:  " ^ (wordToString hs) ^ "\n")
            )
  val _ = print ("        Sys:  " ^ (IntInf.toString o Time.toMilliseconds ) time_sys ^ "\n")
  val _ = print ("        Usr:  " ^ (IntInf.toString o Time.toMilliseconds ) time_usr ^ "\n")
  val _ = print ("   Solution:  " ^ sol_str ^ "\n")
  val _ = print ("      Valid:  " ^ (if sol_val then "yes" else "NO!") ^ "\n")
  val _ = print ("Tour Length:  " ^ (wordToString sol_len) ^ "\n")
  val _ = print ("*********************************\n")
in
  ()
end

val _ = TextIO.print;
val _ = main ()

