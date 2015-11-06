(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature DIST_MAT =
sig

  type t

  val length: t -> int
  (* zero-base indexing *)
  val getDist: t -> word * word -> word
  val readDistFile: string -> t option

end
