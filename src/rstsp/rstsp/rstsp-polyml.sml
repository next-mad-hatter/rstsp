(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

use "rstsp/rstsp-polyml-common.sml";
use "main/defaultsearches.sml";
use "main/trampsearches.sml";
use "main/settings.sig";
use "main/main.sml";

structure Settings: SETTINGS = struct
  val getCmdName = CommandLine.name
  val getArgs = CommandLine.arguments
end

structure Main = MainFn(Settings)

val main = Main.main
