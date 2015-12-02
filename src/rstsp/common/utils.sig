(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Little bits which are used frequently.
 *)
signature UTILS =
sig

  val curry : ('a * 'b -> 'c) -> 'a -> 'b -> 'c

  val uncurry : ('a -> 'b -> 'c) -> 'a * 'b -> 'c

  (**
   * Prints to stderr.
   *)
  val printErr : string -> unit

  (**
   * Deletes all whitespace from string.
   *)
  val stripWS : string -> string

  (**
   * Splits a string at whitespace or commas.
   *)
  val splitString : string -> string list

  val wordToString : word -> string

  val wordFromString : string -> word option

  (**
   * Floored square root.
   *)
  val wordSqrt : word -> word

  val revVector : 'a vector -> 'a vector

  val swap : 'a * 'b -> 'b * 'a

  val power : word * word -> word

end
