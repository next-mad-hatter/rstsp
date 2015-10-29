(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

CM.make "$smlnj-tdp/back-trace.cm";
SMLofNJ.Internals.TDP.mode := true;

use "rstsp_smlnj.sml";

val d = (valOf o DistMat.readDistFile) "../../test/data/small/small.2"
(*
val t1:SBTour.sbtour = SBTour.tourFromILL [[1,2,5]]
val t2:SBTour.sbtour = SBTour.tourFromILL [[1,2,5],[4,3]]
val x = SBTour.tourLength d t1
val s1 = SBTour.tourToString t1
val s2 = SBTour.tourToString t2
val o1 = map SBTour.tourToString (SBTour.balancedOptions t2 0w6)
*)

(*
structure TT = PyrTour
val search = PyrTour.pyrSearch
*)
structure TT = SBTour
val search = SBTour.balancedSearch (SOME 0w4)

val timer = Timer.startCPUTimer ()
val s3 = search d
val ts = (#sys o Timer.checkCPUTimer) timer
val tu = (#usr o Timer.checkCPUTimer) timer
val sol = TT.tourToString s3
val len = TT.tourLength d s3

