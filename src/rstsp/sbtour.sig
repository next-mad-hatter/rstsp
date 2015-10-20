(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature SB_TOUR = sig

  structure WordVectorSet: ORD_SET
  structure WordSet: ORD_SET
  structure WordMap: ORD_MAP

  type sbtour
  (*
  val getSnippets: sbtour -> WordVectorSet.set
  val getKeys: sbtour -> WordSet.set
  val getMap: sbtour -> word vector WordMap.map
  *)

  val empty: sbtour
  val connected: sbtour -> bool

  (* No sanity checks here *)
  val insertSnippet: sbtour * word vector -> sbtour
  val insertSnippet': word vector * sbtour -> sbtour

  val fromILL: int list list -> sbtour
  val tourLength: DistMat.t -> sbtour -> word

  (* TODO:
  val tourToString: sbtour -> string
  *)

end

