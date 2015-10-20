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

val splitString = String.tokens (fn c => c = #" " orelse c = #"\t" orelse c = #",");

val wordToString = Word.fmt StringCvt.DEC

val wordFromString = (StringCvt.scanString (Word.scan StringCvt.DEC))

end
