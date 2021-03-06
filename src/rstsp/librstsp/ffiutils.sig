(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature FFI_UTILS = sig

  val isNull : MLton.Pointer.t -> bool

  val importString : MLton.Pointer.t -> string

  val exportString : string -> MLton.Pointer.t

  val exportSize : int -> MLton.Pointer.t

  val exportCharVector : Word8.word vector -> MLton.Pointer.t

  val exportWordVector : word vector -> MLton.Pointer.t

  val exportLIntVector : Int64.int vector -> MLton.Pointer.t

  val exportPtrVector : MLton.Pointer.t vector -> MLton.Pointer.t

  val importWordVector : MLton.Pointer.t * C_Size.word -> word vector

end
