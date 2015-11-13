(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

open Utils

val distance = (valOf o DistMat.readDistFile) "../../test/data/small/small.2";
(*
val distance = (valOf o DistMat.readDistFile) "../../test/data/random/random.5";
val distance = (valOf o DistMat.readDistFile) "../../test/data/small/small.1";
val distance = (valOf o DistMat.readDistFile) "../../test/data/misc/att48_d.txt";
val distance = (valOf o DistMat.readDistFile) "../../test/data/misc/dantzig42_d.txt";
val distance = (valOf o DistMat.readDistFile) "../../test/data/misc/fri26_d.txt";
val distance = (valOf o DistMat.readDistFile) "../../test/data/misc/gr17_d.txt";
*)
structure SBSearch : TSP_SEARCH = SimpleSearchFn(SBGraph)
structure PyrSearch : TSP_SEARCH = SimpleSearchFn(PyrGraph)

local
  structure P =
  struct
    structure Search = SBSearch
    structure Opts = struct
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
  structure LocalSBSearch = LocalSearchFn(P)
end

local
  structure P =
  struct
    structure Search = PyrSearch
    structure Opts = struct
      fun inv_order size i = i
    end
  end
in
  structure LocalPyrSearch = LocalSearchFn(P)
end

val iter_limit = SOME (IntInf.fromInt 10)
val stale_thresh = SOME (IntInf.fromInt 2)
val rotations = NONE
val node_size = SOME 0w3

(*
val options = (iter_limit, stale_thresh, node_size)
structure Search = LocalSBSearch
*)
val options = (rotations, (iter_limit, stale_thresh, node_size))
structure Search = RotSearchFn(LocalSBSearch)
(*
val options = (rotations, (iter_limit, stale_thresh, ()))
structure Search = RotSearchFn(LocalPyrSearch)
*)


fun main () =
let
  val size = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length distance)))-0w1,0w2)
  val dist = DistMat.getDist distance
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

