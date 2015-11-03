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
(*
 * HACK: SML/NJ has some problem with CML and readDistFile,
 * so we have to call it prior to loading CML.
 *)
(*
val distance = (valOf o DistMat.readDistFile) "../../test/data/misc/dantzig42_d.txt";
*)
CM.autoload "$cml/basis.cm";
CM.autoload "$cml/cml.cm";
CM.autoload "$cml/cml-lib.cm";
use "cmlsearch.sml";
use "tsputils.sml";

(*
use "settings.sig";
use "main.sml";
*)

val _ = TextIO.print;

