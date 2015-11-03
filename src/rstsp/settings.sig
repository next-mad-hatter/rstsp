(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature SETTINGS =
sig

  structure PyrSearch: TSP_SEARCH where type optional_params = unit
  structure SBSearch: TSP_SEARCH where type optional_params = word option
  val getArgs: unit -> string list

end
