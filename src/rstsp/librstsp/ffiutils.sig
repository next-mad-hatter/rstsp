(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature FFI_UTILS = sig

  val importString : MLton.Pointer.t -> String.string

  val exportString : String.string -> MLton.Pointer.t

  val exportCharVector : Word8.word Vector.vector -> MLton.Pointer.t

  val exportWordVector : Word.word Vector.vector -> MLton.Pointer.t

  val exportPtrVector : MLton.Pointer.t Vector.vector -> MLton.Pointer.t

end
