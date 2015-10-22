(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure Utils: UTILS = struct

local
  fun stripChars chars string =
    String.concat (String.tokens
        (fn c => String.isSubstring (String.str c) chars)
      string)
in
  val stripWS = stripChars " \t\r\n"
                       (* (" \t\r\n" ^ str #"\000") *)
end

val splitString = String.tokens
  (fn c =>
    c = #" " orelse c = #"\t" orelse
    c = #"," orelse c = #"\n" orelse
    c = #"\r");

val wordToString = Word.fmt StringCvt.DEC

val wordFromString = (StringCvt.scanString (Word.scan StringCvt.DEC))

val wordSqrt = Word.fromInt o Real.floor o Math.sqrt o Real.fromInt o Word.toInt

fun revVector v = Vector.mapi (fn (i,_) => (Vector.sub (v,Vector.length v-i-1))) v

fun swap (a,b) = (b,a)

end
