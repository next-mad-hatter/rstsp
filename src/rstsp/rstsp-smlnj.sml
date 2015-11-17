(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

CM.make "$smlnj-tdp/back-trace.cm";
SMLofNJ.Internals.TDP.mode := true;

use "common/utils.sig";
use "common/utils.sml";
use "common/lazy.sml";

use "common/numeric.sml";
use "common/distance.sml";
use "common/tsptypes.sml";
use "common/tsputils.sml";

use "tspgraph/tspgraph.sig";
use "tspgraph/pyrgraph.sml";
use "tspgraph/sbutils.sml";
use "tspgraph/sbgraph.sml";

(*
use "tspsearch.sig";
use "simplesearch.sml";
use "localsearch.sml";

use "distmat.sig";
use "distmat.sml";
*)

(*
use "settings.sig";
use "options.sml";
use "main.sml";
*)

val _ = TextIO.print;

