(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature DISTANCE =
sig
  structure Num : NUMERIC

  type dist
  val getDist : dist -> word * word -> Num.num
  val getDim : dist -> word
end

