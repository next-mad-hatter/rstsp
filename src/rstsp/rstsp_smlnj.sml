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
*)

use "utils.sig";
use "utils.sml";
use "distmat.sig";
use "distmat.sml";
use "sbtour.sig";
use "sbtour.sml";

val _ = TextIO.print;