(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature DIST_MAT = sig

  type t

  (* zero-base indexing *)
  val getDist: t -> word * word -> word
  val readDistFile: string -> t option

end
