(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

use "rstsp-polyml.sml";

structure Settings: SETTINGS = struct
  structure PyrSearch : TSP_SEARCH = ThreadedSearchFn(
    struct structure Graph = PyrGraph; structure Store = PyrStore end)
  structure SBSearch : TSP_SEARCH = ThreadedSearchFn(
    struct structure Graph = SBGraph; structure Store = SBStore end)
  val getArgs = CommandLine.arguments
end

structure Main = MainFn(Settings)

val main = Main.main
