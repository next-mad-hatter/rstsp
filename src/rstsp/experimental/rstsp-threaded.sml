(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

use "rstsp/rstsp-polyml-common.sml";
use "threaded/tspstore.sml";
use "threaded/mapstore.sml";
use "threaded/pyrstore.sml";
use "threaded/sbstore.sml";
use "threaded/threadedsearch.sml";
use "threaded/defaultsearches.sml";
use "main/settings.sig";
use "main/main.sml";

structure Settings: SETTINGS = struct
  val getCmdName = CommandLine.name
  val getArgs = CommandLine.arguments
end

structure Main = MainFn(Settings)

val main = Main.main
