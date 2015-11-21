(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure S = DefaultSearches(WordNum)
structure F = FFIUtils

(**
 * We shall prepend the solution by solution length.
 *)
fun extractSol toVec r =
let
  val res = case r of
              NONE => MLton.Pointer.null
            | SOME (len, tour) =>
                F.exportPtrVector (Vector.fromList [
                  (* F.exportSize (Word.toInt len), *)
                  F.exportWordVector (Vector.fromList [len]),
                  F.exportWordVector (toVec (tour ()))
                ])
in
  res
end

val _ =
  _export "rstsp_pyrsearch": (word * MLton.Pointer.t -> MLton.Pointer.t) -> unit;
  (
    fn (size, dist_fn) => (
      let
        val dist = ExtDist.getDist (size,dist_fn)
        val r = #1 ((S.PyrSearch.search size dist NONE false ()) ())
      in
        extractSol S.PyrSearch.tourToVector r
      end
    ) handle _ => MLton.Pointer.null
  )

val _ =
  _export "rstsp_sbsearch": (word * word * MLton.Pointer.t -> MLton.Pointer.t) -> unit;
  (
    fn (max_width, size, dist_fn) => (
      let
        val dist = ExtDist.getDist (size,dist_fn)
        val max_width' = case max_width of
                           0w0 => NONE
                         | _ => SOME max_width
        val r = #1 ((S.SBSearch.search size dist NONE false max_width') ())
      in
        extractSol S.SBSearch.tourToVector r
      end
    ) handle _ => MLton.Pointer.null
  )
