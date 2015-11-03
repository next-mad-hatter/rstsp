(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

use "rstsp-polyml.sml";

structure Settings: SETTINGS = struct
  structure PyrSearch : TSP_SEARCH = SimpleSearchFn(
    struct structure Graph = PyrGraph; structure Store = MapStore(PyrGraph) end)
  structure SBSearch : TSP_SEARCH = SimpleSearchFn(
    struct structure Graph = SBGraph; structure Store = MapStore(SBGraph) end)
  val getArgs = CommandLine.arguments
end

structure Main = MainFn(Settings)

val main = Main.main
