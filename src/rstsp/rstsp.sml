(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

open Utils

fun main file = let
  val _ = print ("Processing " ^ file ^ ": \n")
  val d = DistMat.readDistFile file
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
  else print "  Empty.\n"
end

val _ = let
  val files = SMLofNJ.getArgs ()
in
  if files = [] then print "No input files given.\n"
  else List.app main (SMLofNJ.getArgs ())
end
handle Fail msg => print ("Input Error: " ^ msg ^ "\n")

