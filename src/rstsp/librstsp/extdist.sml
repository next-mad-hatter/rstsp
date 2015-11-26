(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure ExtDist : DISTANCE =
struct

  structure Num = IntNum

  (**
   * We expect here:
   *   - problem size
   *   - a (word * word -> word) distance function pointer
   *)
  type dist = word * MLton.Pointer.t

  val dist_fn = _import * : MLton.Pointer.t -> word * word -> Int64.int;

  fun getDim (d,_) = d

  fun getDist (_,f) (i,j) = (Int64.toLarge o (dist_fn f)) (i,j)

end
