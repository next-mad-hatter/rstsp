(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure ExtDist : DISTANCE =
struct

  structure Num = WordNum

  (**
   * We expect here:
   *   - problem size
   *   - a (word * word -> word) distance function pointer
   *)
  type dist = word * MLton.Pointer.t

  val dist_fn = _import * : MLton.Pointer.t -> word * word -> word;

  fun getDim (d,_) = d

  fun getDist (_,f) (i,j) = (dist_fn f) (i,j)

end
