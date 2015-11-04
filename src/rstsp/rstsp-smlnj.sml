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
use "distmat.sig";
use "distmat.sml";
use "tspgraph.sig";
use "pyrgraph.sml";
use "sbutils.sml";
use "sbgraph.sml";
use "tspsearch.sig";
use "tspstore.sig";
use "mapstore.sml";
use "pyrstore.sml";
use "simplesearch.sml";
use "tsputils.sml";

(*
use "settings.sig";
use "main.sml";
*)

val _ = TextIO.print;

