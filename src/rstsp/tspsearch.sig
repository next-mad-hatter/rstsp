(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature TSP_SEARCH = sig

  type tour

  structure Tour: TSP_TOUR where type tour = tour

  val search: word -> (word * word -> word) -> unit -> tour option

end
