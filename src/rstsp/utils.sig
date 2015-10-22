(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(*
 * Little bits which have no particular place.
 *)
signature UTILS = sig

  (* deletes all whitespace from string *)
  val stripWS: String.string -> String.string

  val splitString: String.string -> String.string list

  val wordToString: Word.word -> String.string

  val wordFromString: String.string -> Word.word option

  val wordSqrt: Word.word -> Word.word

  val revVector: 'a vector -> 'a vector

  val swap: 'a * 'b -> 'b * 'a

end