(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

open Utils

fun read file =
  (DistMat.readDistFile file)
    handle Fail msg => (print ("  Input Error: " ^ msg ^ "\n"); NONE)

structure Search : TSP_SEARCH = TSPSearchFn(PyrGraph)

fun main file = let
  val _ = print ("===================================================\n")
  val _ = print ("Processing " ^ file ^ ": \n")
  val _ = print ("===================================================\n")
  val d = read file
in
  if isSome d andalso (Vector.length o valOf) d > 1 then
    let
      val dist = DistMat.getDist (valOf d)
      val size = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (Vector.length (valOf d))))-0w1,0w2)
      val search = Search.search size dist
      val timer = Timer.totalCPUTimer ()
      val sol = valOf (search ())
      val stop = Timer.checkCPUTimer timer
      val sys = (IntInf.toString o Time.toMilliseconds o #sys) stop
      val usr = (IntInf.toString o Time.toMilliseconds o #usr) stop
      val sol_vec = Search.Tour.toVector sol
      val sol_str = Search.Tour.toString sol
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
  (* case CommandLine.name () *)
    case (mstr, wordFromString mstr) of
         ("p",_) =>
           (
             List.app main files;
             ()
           )
       | (_, SOME _) => print "Not implemented.\n"
       | _ => print "Invalid input.\n"
end

