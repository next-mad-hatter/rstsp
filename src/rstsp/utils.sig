(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(*
 * Little bits which have no particular place.
 *)
signature UTILS =
sig

  val curry: ('a * 'b -> 'c) -> 'a -> 'b -> 'c
  val uncurry: ('a -> 'b -> 'c) -> 'a * 'b -> 'c

  (* prints to stderr *)
  val printErr: string -> unit

  (* deletes all whitespace from string *)
  val stripWS: String.string -> String.string

  val splitString: String.string -> String.string list

  val wordToString: Word.word -> String.string

  val wordFromString: String.string -> Word.word option

  val wordSqrt: Word.word -> Word.word

  val revVector: 'a vector -> 'a vector

  val swap: 'a * 'b -> 'b * 'a

  structure WordPairSet : ORD_SET
  structure WordPairSetSet : ORD_SET

end
