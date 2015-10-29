(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature SB_TOUR = sig

  type sbtour

  val tourToString: sbtour -> string
  val tourLength: DistMat.t -> sbtour -> word
  val balancedSearch: word option -> DistMat.t -> sbtour

end

