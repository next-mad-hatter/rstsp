(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * These are not part of SML specification
 * and thus differ for different implementations.
 *)
signature SETTINGS =
sig
  val getCmdName: unit -> string
  val getArgs: unit -> string list
end
