(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

open Utils

structure NSrch : SEARCHES = DefaultSearches(WordNum)

val node_size = SOME 0w3
val iter_limit = SOME (IntInf.fromInt 10)
val stale_thresh = SOME (IntInf.fromInt 2)
val rotations = NONE

val options = (rotations, (iter_limit, stale_thresh, (node_size)))
structure Search = NSrch.RotSBSearch

val inst = TsplibReader.readTSPFile "../../test/data/tsplib/gr17.tsp"
structure Dist = NatDist
datatype tsplib_inst = datatype TsplibReader.tsplib_inst
val data = case inst of
             EXPLICIT_INSTANCE v => v
           | EUCLIDEAN_2D_INSTANCE (xs,ys) => raise Fail "not here"
structure LenCheck = TSPLengthFn(Dist)

fun main () =
let
  val dist = Dist.getDist data
  val size = Dist.getDim data
  val search = Search.search size dist NONE true options
  val (sol', stats) = search ()
  val (sol_len, sol_fn) = valOf sol'
  val sol = sol_fn ()
  val _ = print ("*********************************\n")
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
      val len_val = Dist.Num.compare(sol_len, LenCheck.tourLength data sol_vec) = EQUAL
      val sol_val = TSPUtils.validTour size sol_vec
    in
      print ("    Solution valid:  " ^ (if sol_val andalso len_val then "yes" else "NO!") ^ "\n")
    end
  val _ = print ("   Solution:  " ^ (Search.tourToString sol) ^ "\n")
  val _ = print ("Tour Length:  " ^ (wordToString sol_len) ^ "\n")
  val _ = print ("*********************************\n")
in
  ()
end

val _ = TextIO.print;
val _ = main ()

