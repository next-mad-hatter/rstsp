(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

use "rstsp/rstsp-polyml-common.sml";
use "experimental/tspstore.sig";
use "experimental/mapstore.sml";
use "experimental/pyrstore.sml";
use "experimental/sbstore.sml";
use "experimental/threadedsearch.sml";
use "experimental/defaultsearches.sml";
use "main/settings.sig";
use "main/main.sml";

structure Settings: SETTINGS = struct
  val getCmdName = CommandLine.name
  val getArgs = CommandLine.arguments
end

structure Main = MainFn(Settings)

val main = Main.main
