(*
 * $File$
 *
 * $Author$
 * $Date$
 * $Revision$
 *)

(*
 * This loads dependencies for use in sml/nj shell.
 * Shouldn't it load these on mention/demand?
 *)
(*
CM.autoload "$/regexp-lib.cm";
CM.autoload "$MLTON_LIB/com/ssh/generic/unstable/lib.cm";
*)

CM.make "$smlnj-tdp/back-trace.cm";
SMLofNJ.Internals.TDP.mode := true;

use "utils.sig";
use "utils.sml";
use "distmat.sig";
use "distmat.sml";
use "tspgraph.sig";
use "pyrgraph.sml";
use "tspsearch.sig";
use "tspsearch.sml";
use "tsputils.sml";

val _ = TextIO.print;
