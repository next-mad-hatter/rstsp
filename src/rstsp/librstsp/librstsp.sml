(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure S = DefaultSearches(IntNum)
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
                  F.exportLIntVector (Vector.fromList [Int64.fromLarge len]),
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

val _ =
  _export "rstsp_ad_sb_search": (word * MLton.Pointer.t * word * word * word * word * word -> MLton.Pointer.t) -> unit;
  (
    fn (size, dist_fn, max_width, max_iters, stale_iters, min_rots, max_rots) => (
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
        val r = #1 ((S.AdSBSearch.search size dist NONE false (max_iters', stale_iters', min_rots, SOME max_rots, max_width')) ())
      in
        extractSol S.AdSBSearch.tourToVector r
      end
    ) handle _ => MLton.Pointer.null
  )

val _ =
  _export "rstsp_ff_search": (word * MLton.Pointer.t * word * word * word * word * word * word -> MLton.Pointer.t) -> unit;
  (
    fn (size, dist_fn, max_width, max_iters, stale_iters, min_rots, max_rots, max_flips) => (
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
        val max_flips' = case max_flips of
                           0w0 => NONE
                         | m => SOME ((IntInf.fromInt o Word.toInt) m)
        val r = #1 (S.FlipFlopSearch.search size dist NONE false (max_flips', SOME 1,
                                                                   (max_iters', stale_iters', ()),
                                                                   (max_iters', stale_iters', min_rots, SOME max_rots, max_width')) ())
      in
        extractSol S.FlipFlopSearch.tourToVector r
      end
    ) handle _ => MLton.Pointer.null
  )

