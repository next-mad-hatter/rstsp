(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure FFI = FFIUtils
structure Searches = DefaultSearches(WordNum)

(**
 * For now, we return the solution as vector.
 * Prepended are error status and solution length.
 *)
fun extractSol toVec r =
let
  val res = case r of
              NONE => Vector.fromList [0w1]
            | SOME (len, tour) =>
                let
                  val head = VectorSlice.full (Vector.fromList [0w0, len])
                  val tail = VectorSlice.full (toVec (tour ()))
                in
                  VectorSlice.concat [head,tail]
                end
in
  FFI.exportWordVector res
end

val _ =
  _export "rstsp_pyrsearch": (word * MLton.Pointer.t -> MLton.Pointer.t) -> unit;
  (
    fn (size, dist_fn) =>
    let
      val dist = ExtDist.getDist (size,dist_fn)
      val r = #1 ((Searches.PyrSearch.search size dist NONE false ()) ())
    in
      extractSol Searches.PyrSearch.tourToVector r
    end
  )

val _ =
  _export "rstsp_sbsearch": (word * word * MLton.Pointer.t -> MLton.Pointer.t) -> unit;
  (
    fn (max_width, size, dist_fn) =>
    let
      val dist = ExtDist.getDist (size,dist_fn)
      val max_width' = case max_width of
                         0w0 => NONE
                       | _ => SOME max_width
      val r = #1 ((Searches.SBSearch.search size dist NONE false max_width') ())
    in
      extractSol Searches.SBSearch.tourToVector r
    end
  )
