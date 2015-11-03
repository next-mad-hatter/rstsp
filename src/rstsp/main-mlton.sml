(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure settings: SETTINGS =
struct
  structure PyrSearch : TSP_SEARCH = SimpleSearchFn(PyrGraph)
  structure SBSearch : TSP_SEARCH = SimpleSearchFn(SBGraph)
  val getArgs = SMLofNJ.getArgs
end
structure Main = MainFn(settings)

val _ = Main.main ()
