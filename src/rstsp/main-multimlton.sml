(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure settings: SETTINGS =
struct
  structure PyrSearch : TSP_SEARCH = PacmlSearchFn(PyrGraph)
  structure SBSearch : TSP_SEARCH = PacmlSearchFn(SBGraph)
  val getArgs = SMLofNJ.getArgs
end
structure Main = MainFn(settings)

val _ = MLton.Pacml.run (
  fn () => (Main.main (); print "DONE\n"; OS.Process.exit OS.Process.success)
)
