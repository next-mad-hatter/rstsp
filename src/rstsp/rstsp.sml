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

fun main (tourToString,tourLength,search) file = let
  val _ = print ("===================================================\n")
  val _ = print ("Processing " ^ file ^ ": \n")
  val _ = print ("===================================================\n")
  val d = read file
in
  if isSome d andalso (Vector.length o valOf) d > 1 then
    let
      val timer = Timer.totalCPUTimer ()
      val t = search (valOf d)
      val stop = Timer.checkCPUTimer timer
      val sys = (IntInf.toString o Time.toMilliseconds o #sys) stop
      val usr = (IntInf.toString o Time.toMilliseconds o #usr) stop
    in
      print ("  Sys: " ^ sys ^ "ms\n");
      print ("  Usr: " ^ usr ^ "ms\n");
      print ("  Tour: " ^ (tourToString t) ^ "\n");
      print ("  Length: " ^ (wordToString (tourLength (valOf d) t)) ^ "\n")
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
           ( List.app (main
             (PyrTour.tourToString,PyrTour.tourLength,PyrTour.pyrSearch)) files;
             ()
           )
       | (_, SOME m) =>
           ( List.app (main
             (SBTour.tourToString,SBTour.tourLength,SBTour.balancedSearch (if m>0w0 then SOME m else NONE))) files;
             () )
       | _ => print "Invalid input.\n"
end

