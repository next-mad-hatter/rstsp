(*
 * $File$
 *
 * $Author$
 * $Date$
 * $Revision$
 *)

(*
 * This loads all dependencies for use in sml/nj shell.
 * Shouldn't it load these on mention/demand?
 *)
(*
CM.autoload "$/regexp-lib.cm";
CM.autoload "$MLTON_LIB/com/ssh/generic/unstable/lib.cm";
*)

use "utils.sig";
use "utils.sml";
use "distmat.sig";
use "distmat.sml";
use "sbtour.sig";
use "sbtour.sml";
use "pyrtour.sig";
use "pyrtour.sml";

val _ = TextIO.print;
