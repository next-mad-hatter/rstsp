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
   * FIXME: annotate & hide unnecessary things
   *)

  val getSnippets: sbtour -> WordVectorSet.set
  (*
  val getKeys: sbtour -> WordSet.set
  val getMap: sbtour -> word vector WordMap.map
  *)

  val empty: sbtour
  val isConnected: sbtour -> bool

  (* No sanity checks here *)
  val insertSnippet: sbtour * word vector -> sbtour
  val insertSnippet': word vector * sbtour -> sbtour
  val removeSnippetFrom: sbtour * word -> sbtour * word vector
  val removeSnippetFrom': word * sbtour -> sbtour * word vector
  (* Attention: one-based! *)
  val snippetToString: word vector -> string

  val tourFromILL: int list list -> sbtour
  val tourToString: sbtour -> string
  val tourLength: DistMat.t -> sbtour -> word

  (*
  val balancedOptions: sbtour -> word -> sbtour list
  *)
  val balancedSearch: DistMat.t -> sbtour

end

