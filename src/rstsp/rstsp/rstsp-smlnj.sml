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
use "common/distance.sig";
use "common/tsptypes.sml";
use "common/tsputils.sml";
use "common/distance.sml";

use "tspgraph/tspgraph.sig";
use "tspgraph/pyrgraph.sml";
use "tspgraph/sbutils.sml";
use "tspgraph/sbgraph.sml";

use "tspsearch/tspsearch.sig";
use "tspsearch/simplesearch.sml";
use "tspsearch/itersearch.sml";
use "tspsearch/rotsearch.sml";
use "tspsearch/adaptivesearch.sml";

use "main/options.sml";
use "main/tspread.sml";
use "main/searches.sig";
use "main/defaultsearches.sml";
use "main/settings.sig";
use "main/main.sml";

val _ = TextIO.print;
