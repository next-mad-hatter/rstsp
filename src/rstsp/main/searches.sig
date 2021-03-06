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
  structure IterPyrSearch : TSP_SEARCH
  structure IterSBSearch : TSP_SEARCH
  structure IterRotPyrSearch : TSP_SEARCH
  structure IterRotSBSearch : TSP_SEARCH
  structure AdPyrSearch : TSP_SEARCH
  structure AdSBSearch : TSP_SEARCH
  structure FlipFlopSearch : TSP_SEARCH
 end
