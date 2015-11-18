(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * The readers are not part of SML specification
 * and thus differ for different implementations.
 *)
signature SETTINGS =
sig
  val getCmdName : unit -> string
  val getArgs : unit -> string list
end
