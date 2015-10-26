(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature PYR_TOUR = sig

  type pyrtour

  val tourToString: pyrtour -> string
  val tourLength: DistMat.t -> pyrtour -> word
  val pyrSearch: DistMat.t -> pyrtour

end

