(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Searches to be used in main.  These can differ for, e.g, threaded implementation etc.
 *)
 signature SEARCHES =
 sig
  structure PyrSearch : TSP_SEARCH
  structure SBSearch : TSP_SEARCH
  structure RotPyrSearch : TSP_SEARCH
  structure RotSBSearch : TSP_SEARCH
 end
