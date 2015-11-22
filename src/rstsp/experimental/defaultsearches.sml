(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

functor DefaultSearches(N : NUMERIC) : SEARCHES =
struct

  structure PyrSearch : TSP_SEARCH = ThreadedSearchFn(
    struct structure Graph = PyrGraph(N); structure Store = PyrStore(N) end)
  structure SBSearch : TSP_SEARCH = ThreadedSearchFn(
    struct structure Graph = SBGraph(N); structure Store = SBStore(N) end)

  local
    fun cycle size n = fn i => Word.mod (n + i, size)
    fun inv_order size i =
    let
      val size' = Word.toInt size
      val i' = Word.toInt i
      val j = case Int.mod(i',2) of
                0 => Real.floor (Real.fromInt (size'-i'-1) / Real.fromInt 2)
              | _ => Real.ceil (Real.fromInt (size'+i'-1) / Real.fromInt 2)
    in
      Word.fromInt j
    end
  in
    structure RotPyrSearch = RotSearchFn(
      struct
        structure Search = PyrSearch
        val perm = cycle
      end
    )
    structure RotSBSearch = RotSearchFn(
      struct
        structure Search = SBSearch
        fun perm size n = (cycle size n) o (inv_order size)
      end
    )
  end

  local
    fun inv_order _ i = i
  in
    structure IterPyrSearch = IterSearchFn(
      struct
        structure Search = PyrSearch
        val inv_order = inv_order
      end)
    structure IterRotPyrSearch = IterSearchFn(
      struct
        structure Search = RotPyrSearch
        val inv_order = inv_order
      end)
  end

  local
    fun inv_order size i =
    let
      val size' = Word.toInt size
      val i' = Word.toInt i
      val j = case Int.mod(i',2) of
                0 => Real.floor (Real.fromInt (size'-i'-1) / Real.fromInt 2)
              | _ => Real.ceil (Real.fromInt (size'+i'-1) / Real.fromInt 2)
    in
      Word.fromInt j
    end
  in
    structure IterSBSearch = IterSearchFn(
      struct
        structure Search = SBSearch
        val inv_order = inv_order
      end)
    structure IterRotSBSearch = IterSearchFn(
      struct
        structure Search = RotSBSearch
        val inv_order = inv_order
      end)
  end

end
