(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

use "rstsp-polyml.sml";

structure Settings: SETTINGS = struct
  structure PyrSearch : TSP_SEARCH = SimpleSearchFn(PyrGraph)
  structure SBSearch : TSP_SEARCH = SimpleSearchFn(SBGraph)
  val getCmdName = CommandLine.name
  val getArgs = CommandLine.arguments
end

structure Main = MainFn(Settings)

val main = Main.main
