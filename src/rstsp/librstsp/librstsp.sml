(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure S = DefaultSearches(WordNum)
structure F = FFIUtils

(**
 * If we would rather return a struct pointer,
 * we would have to deal with alignment.
 *)
fun extractSol toVec r =
let
  val res = case r of
              NONE => MLton.Pointer.null
            | SOME (len, tour) =>
                F.exportPtrVector (Vector.fromList [
                  F.exportWordVector (Vector.fromList [len]),
                  F.exportWordVector (toVec (tour ()))
                ])
in
  res
end

val _ =
  _export "rstsp_pyr_search": (word * MLton.Pointer.t * MLton.Pointer.t -> MLton.Pointer.t) -> unit;
  (
    fn (size, dist_fn, filename) => (
      let
        val dist = ExtDist.getDist (size,dist_fn)
        val file = case F.isNull filename of
                     true => NONE
                   | _ => SOME (F.importString filename)
        val r = #1 ((S.PyrSearch.search size dist file false ()) ())
      in
        extractSol S.PyrSearch.tourToVector r
      end
    ) handle _ => MLton.Pointer.null
  )

val _ =
  _export "rstsp_sb_search": (word * MLton.Pointer.t * word * MLton.Pointer.t -> MLton.Pointer.t) -> unit;
  (
    fn (size, dist_fn, max_width, filename) => (
      let
        val dist = ExtDist.getDist (size,dist_fn)
        val file = case F.isNull filename of
                     true => NONE
                   | _ => SOME (F.importString filename)
        val max_width' = case max_width of
                           0w0 => NONE
                         | _ => SOME max_width
        val r = #1 ((S.SBSearch.search size dist file false max_width') ())
      in
        extractSol S.SBSearch.tourToVector r
      end
    ) handle _ => MLton.Pointer.null
  )

val _ =
  _export "rstsp_iter_pyr_search": (word * MLton.Pointer.t * word * word * word -> MLton.Pointer.t) -> unit;
  (
    fn (size, dist_fn, max_iters, stale_iters, max_rots) => (
      let
        val dist = ExtDist.getDist (size,dist_fn)
        val max_iters' = case max_iters of
                           0w0 => NONE
                         | m => SOME ((IntInf.fromInt o Word.toInt) m)
        val stale_iters' = case stale_iters of
                             0w0 => NONE
                           | m => SOME ((IntInf.fromInt o Word.toInt) m)
        val r = #1 ((S.IterRotPyrSearch.search size dist NONE false (max_iters', stale_iters', (SOME max_rots, ()))) ())
      in
        extractSol S.IterRotPyrSearch.tourToVector r
      end
    ) handle _ => MLton.Pointer.null
  )

val _ =
  _export "rstsp_iter_sb_search": (word * MLton.Pointer.t * word * word * word * word -> MLton.Pointer.t) -> unit;
  (
    fn (size, dist_fn, max_width, max_iters, stale_iters, max_rots) => (
      let
        val dist = ExtDist.getDist (size,dist_fn)
        val max_width' = case max_width of
                           0w0 => NONE
                         | _ => SOME max_width
        val max_iters' = case max_iters of
                           0w0 => NONE
                         | m => SOME ((IntInf.fromInt o Word.toInt) m)
        val stale_iters' = case stale_iters of
                             0w0 => NONE
                           | m => SOME ((IntInf.fromInt o Word.toInt) m)
        val r = #1 ((S.IterRotSBSearch.search size dist NONE false (max_iters', stale_iters', (SOME max_rots, max_width'))) ())
      in
        extractSol S.IterRotSBSearch.tourToVector r
      end
    ) handle _ => MLton.Pointer.null
  )

