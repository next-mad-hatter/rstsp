(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature TSP_SEARCH = sig

  type tour
  type optional_params

  structure Tour: TSP_TOUR where type tour = tour

  val search: word -> (word * word -> word) -> optional_params -> unit -> tour option

end
