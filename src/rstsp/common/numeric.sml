(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Without first-class polymorphism / higher-order modules / type classes
 * we have to resort to this.
 *)
signature NUMERIC =
sig
  type num
  val + : num * num -> num
  val zero : num
  val compare : num * num -> order
  val toString : num -> string
end

(**
 * SML calls its floating point numbers reals for historical reasons --
 * we're sticking with it as well.
 *)
structure RealNum : NUMERIC =
struct
  type num = Real.real
  val op+ = Real.+
  val zero = 0.0
  val compare = Real.compare
  val toString = Real.toString
end

structure WordNum : NUMERIC =
struct
  type num = Word.word
  val op+ = Word.+
  val zero = 0w0
  val compare = Word.compare
  val toString = Utils.wordToString
end
