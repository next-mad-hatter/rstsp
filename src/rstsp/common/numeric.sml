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
  val fromInt : int -> num
  val toInt : num -> int
  val fromString : string -> num option
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
  val fromInt = Real.fromInt
  val toInt = Real.floor
  val fromString = Real.fromString
  val toString = Real.toString
end

structure IntNum : NUMERIC =
struct
  type num = IntInf.int
  val op+ = IntInf.+
  val zero = IntInf.fromInt 0
  val compare = IntInf.compare
  val fromInt = IntInf.fromInt
  val toInt = IntInf.toInt
  val fromString = IntInf.fromString
  val toString = IntInf.toString
end
