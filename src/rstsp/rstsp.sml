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

fun main file = let
  val _ = print ("Processing " ^ file ^ ": \n")
  val d = read file
in
  if isSome d andalso (Vector.length o valOf) d > 1 then
    let
      val timer = Timer.totalCPUTimer ()
      val t = SBTour.balancedSearch (valOf d)
      val stop = Timer.checkCPUTimer timer
      val sys = (IntInf.toString o Time.toMilliseconds o #sys) stop
      val usr = (IntInf.toString o Time.toMilliseconds o #usr) stop
    in
      print ("  Sys: " ^ sys ^ "ms\n");
      print ("  Usr: " ^ usr ^ "ms\n");
      print ("  Tour: " ^ (SBTour.tourToString t) ^ "\n");
      print ("  Length: " ^ (wordToString (SBTour.tourLength (valOf d) t)) ^ "\n")
    end
  else print "  Empty problem.\n"
end

val _ = let
  val files = SMLofNJ.getArgs ()
in
  if files = [] then print "No input files given.\n"
  else List.app main (SMLofNJ.getArgs ())
end

