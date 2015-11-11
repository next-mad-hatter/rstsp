(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

open Utils

val distance = (valOf o DistMat.readDistFile) "../../test/data/random/random.100";
(*
val distance = (valOf o DistMat.readDistFile) "../../test/data/small/small.1";
val distance = (valOf o DistMat.readDistFile) "../../test/data/misc/att48_d.txt";
val distance = (valOf o DistMat.readDistFile) "../../test/data/misc/dantzig42_d.txt";
val distance = (valOf o DistMat.readDistFile) "../../test/data/misc/fri26_d.txt";
val distance = (valOf o DistMat.readDistFile) "../../test/data/misc/gr17_d.txt";
*)
val iter_limit = 50

structure Search : TSP_SEARCH = SimpleSearchFn(SBGraph)
val options = SOME 0w3
local
  structure P =
  struct
    structure Search = Search
    structure Opts = struct
      val iter_limit = IntInf.fromInt iter_limit
      fun inv_order size i =
      let
        val size' = Word.toInt size
        val i' = Word.toInt i
        val j = case Int.mod(i',2) of
                  0 => Real.floor (Real.fromInt (size'-i'-1) / Real.fromInt 2)
                | _ => Real.ceil (Real.fromInt (size'+i'-1) / Real.fromInt 2)
      in
        Word.fromInt j
      end
    end
  end
in
  structure LocalSearch = LocalSearchFn(P)
end
(*
*)
(*
structure Search : TSP_SEARCH = SimpleSearchFn(PyrGraph)
val options = ()
local
  structure P =
  struct
    structure Search = Search
    structure Opts = struct
      val iter_limit = IntInf.fromInt iter_limit
      fun inv_order size i = i
    end
  end
in
  structure LocalSearch = LocalSearchFn(P)
end
*)

fun main () =
let
  val size = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length distance)))-0w1,0w2)
  val dist = DistMat.getDist distance
  val search = LocalSearch.search size dist NONE true options
  val timer = Timer.startCPUTimer ()
  val (sol', stats) = search ()
  val sol = (valOf sol') ()
  val (nn, nk, hs) = valOf stats
  val time_sys = (#sys o Timer.checkCPUTimer) timer
  val time_usr = (#usr o Timer.checkCPUTimer) timer
  val sol_vec = LocalSearch.toVector sol
  val sol_str = LocalSearch.toString sol
  val sol_len = tourLength dist sol_vec
  val sol_val = validTour size sol_vec
  val _ = print ("*********************************\n")
  val _ = print ("   Solution:  " ^ sol_str ^ "\n")
  val _ = print ("      Valid:  " ^ (if sol_val then "yes" else "NO!") ^ "\n")
  val _ = print ("     Length:  " ^ (wordToString sol_len) ^ "\n")
  val _ = print (" Node Types:  " ^ (wordToString nk) ^ "\n")
  val _ = print (" Store size:  " ^ (wordToString nn) ^ "\n");
  val _ = print ("Node hashes:  " ^ (wordToString hs) ^ "\n");
  val _ = print ("        Sys:  " ^ (IntInf.toString o Time.toMilliseconds ) time_sys ^ "\n")
  val _ = print ("        Usr:  " ^ (IntInf.toString o Time.toMilliseconds ) time_usr ^ "\n")
  val _ = print ("*********************************\n")
in
  ()
end

val _ = TextIO.print;
val _ = main ()

