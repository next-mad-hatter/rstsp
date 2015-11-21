(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure FFIUtils: FFI_UTILS = struct

  val malloc = _import "malloc": C_Size.word -> MLton.Pointer.t;
  val free = _import "free": MLton.Pointer.t -> unit;

  fun isNull p = p = MLton.Pointer.null

  fun cStringSub (s, i) = Byte.byteToChar (MLton.Pointer.getWord8 (s, i))

  fun cStringSize s =
  let
    fun loop i = if #"\000" = cStringSub (s, i) then i else loop (i+1)
  in
    loop 0
  end

  fun importString s =
    if isNull s then raise Fail "Null string"
    else CharVector.tabulate (cStringSize s, fn i => cStringSub (s, i))

  fun exportSize s =
  let
    val p = malloc (C_Size.fromInt 1)
    val _ = if isNull p then raise Fail "Out of memory" else ()
  in
    MLton.Pointer.setWord32 (p, 0, Word.fromInt s);
    p
  end

  fun exportString s =
  let
    val p = malloc (C_Size.fromInt (String.size s + 1))
    val _ = if isNull p then raise Fail "Out of memory" else ()
  in
    List.foldl (fn (c,i) =>
      (MLton.Pointer.setWord8 (p, i, Byte.charToByte c); i+1)) 0 (String.explode s);
    MLton.Pointer.setWord8 (p, String.size s, 0w0);
    p
  end

  fun vectorExporter size setter =
  let
    fun exp v =
    let
      val p = malloc (0w1 + size * C_Size.fromInt (Vector.length v))
      val _ = if isNull p then raise Fail "Out of memory" else ()
    in
      Vector.appi (fn (i,x) => setter (p, i, x)) v;
      p
    end
  in
    exp
  end
  val exportCharVector = vectorExporter 0w1 MLton.Pointer.setWord8
  val exportWordVector = vectorExporter 0w4 MLton.Pointer.setWord32
  val exportPtrVector = vectorExporter
        (C_Size.fromInt (Word.toInt MLton.Pointer.sizeofPointer)) MLton.Pointer.setPointer

  fun importVector getter (p,size) =
    Vector.tabulate (C_Size.toInt size, fn i => getter (p, i))

  val importWordVector = importVector MLton.Pointer.getWord32

end
