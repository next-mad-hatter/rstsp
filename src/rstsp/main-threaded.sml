(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

use "rstsp-polyml.sml";
use "threadedsearch.sml";
use "settings.sig";
use "main.sml";

structure Settings: SETTINGS = struct
  structure PyrSearch : TSP_SEARCH = ThreadedSearchFn(PyrGraph)
  structure SBSearch : TSP_SEARCH = ThreadedSearchFn(SBGraph)
  val getArgs = CommandLine.arguments
end

structure Main = MainFn(Settings)

val main = Main.main
