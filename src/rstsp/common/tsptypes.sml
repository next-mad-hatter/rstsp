(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure TSPTypes =
struct

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

end
