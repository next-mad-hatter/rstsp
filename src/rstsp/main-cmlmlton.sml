(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure settings: SETTINGS =
struct
  structure PyrSearch : TSP_SEARCH = CMLSearchFn(PyrGraph)
  structure SBSearch : TSP_SEARCH = CMLSearchFn(SBGraph)
  val getArgs = SMLofNJ.getArgs
end
structure Main = MainFn(settings)

val quantum = SOME (Time.fromMilliseconds 10)
val _ = RunCML.doit (fn () =>
  (
    Main.main ();
    RunCML.shutdown OS.Process.success;
    ()
  ), quantum)
