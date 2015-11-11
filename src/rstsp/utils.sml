(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure Utils: UTILS = struct

  val curry = fn f => fn x => fn y => f(x, y);
  val uncurry = fn f => fn (x, y) => f x y;

  fun printErr s = (
    TextIO.output (TextIO.stdErr, s);
    TextIO.flushOut TextIO.stdErr
  )

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

  local
    structure WordPairKey = struct
      type ord_key = word * word
      fun compare ((w,s),(w',s')) = let
        val comp = Word.compare (w,w')
      in
        if comp = EQUAL then Word.compare (s,s') else comp
      end
    end
  in
    structure WordPairSet: ORD_SET = SplaySetFn(WordPairKey)
  end
  local
    structure WordPairSetKey = struct
      type ord_key = WordPairSet.set
      val compare = WordPairSet.compare
    end
  in
    structure WordPairSetSet = SplaySetFn(WordPairSetKey)
  end

  fun power (a,p) =
  let
    fun pr (a,_,0w0) = a
      | pr (a,v,n) = pr (a,v*a,n-0w1)
  in
    pr (a,0w1,p)
  end

end
