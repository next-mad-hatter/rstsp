(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

open Utils

fun main file = let
  val _ = (print "Reading "; print file; print ": ")
  val d = DistMat.readDistFile file
  val _ = print "done.\n"
in
  if isSome d then
    (*
    (Vector.app (fn x => (print (wordToString x); print " ")) (valOf d); print "\n";
     print "Processed.\n")
    *)
    print "Processed.\n"
  else print "Empty.\n"
end

val _ = List.app main (SMLofNJ.getArgs ())
handle Fail msg => print ("Input Error: " ^ msg ^ "\n")

