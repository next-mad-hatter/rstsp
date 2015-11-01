(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

open Utils

structure PyrSearch : TSP_SEARCH = TSPSearchFn(PyrGraph)
structure SBSearch : TSP_SEARCH = TSPSearchFn(SBGraph)

fun read file =
  (DistMat.readDistFile file)
    handle Fail msg => (print ("  Input Error: " ^ msg ^ "\n"); NONE)

fun main (search, to_vec, to_str) file = let
  val _ = print ("===================================================\n")
  val _ = print ("Processing " ^ file ^ ": \n")
  val _ = print ("===================================================\n")
  val d = read file
in
  if isSome d andalso (Vector.length o valOf) d > 1 then
    let
      val dist = DistMat.getDist (valOf d)
      val size = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length (valOf d))))-0w1,0w2)
      val timer = Timer.totalCPUTimer ()
      val sol = valOf (search (size,dist) ())
      val stop = Timer.checkCPUTimer timer
      val sys = (IntInf.toString o Time.toMilliseconds o #sys) stop
      val usr = (IntInf.toString o Time.toMilliseconds o #usr) stop
      val sol_vec = to_vec sol
      val sol_str = to_str sol
      val sol_len = tourLength dist sol_vec
      val sol_val = validTour size sol_vec
    in
      print ("  Sys: " ^ sys ^ "ms\n");
      print ("  Usr: " ^ usr ^ "ms\n");
      print ("  Tour: " ^ sol_str ^ "\n");
      print ("  Valid: " ^ (if sol_val then "yes" else "NO!") ^ "\n");
      print ("  Length: " ^ (wordToString sol_len) ^ "\n")
    end
  else print "  Empty problem.\n"
end

val _ = let
  val args = SMLofNJ.getArgs ()
in
  case args of
       [] => print "Expected arguments: max_width|\"p\" file(s)\n"
     | _::[] => print "No input files given.\n"
     | mstr::files =>
         case (mstr, wordFromString mstr) of
           ("p",_) => List.app (main
               (fn (size,dist) => PyrSearch.search size dist
                                    (SOME "log.dot") (),
                PyrSearch.Tour.toVector,
                PyrSearch.Tour.toString))
             files
         | (_, SOME m) => List.app (main
               (fn (size,dist) => SBSearch.search size dist
                                    (SOME "log.dot") (if m = 0w0 then NONE else SOME m),
                SBSearch.Tour.toVector,
                SBSearch.Tour.toString))
             files
         | _ => print "Invalid input.\n"
end

