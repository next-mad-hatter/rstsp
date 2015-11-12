(*
 * $File$
 *
 * $Author$
 * $Date$
 * $Revision$
 *)

CM.make "$smlnj-tdp/back-trace.cm";
SMLofNJ.Internals.TDP.mode := true;

(*
CM.autoload "$/regexp-lib.cm";
CM.autoload "$MLTON_LIB/com/ssh/generic/unstable/lib.cm";
*)

use "utils.sig";
use "utils.sml";

use "lazy.sml";

use "distmat.sig";
use "distmat.sml";

use "tspgraph.sig";
use "pyrgraph.sml";
use "sbutils.sml";
use "sbgraph.sml";

use "tspsearch.sig";

use "simplesearch.sml";
use "tsputils.sml";
use "localsearch.sml";

(*
use "settings.sig";
use "options.sml";
use "main.sml";
*)

val _ = TextIO.print;

