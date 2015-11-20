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
    structure P =
    struct
      structure Search = PyrSearch
      structure Opts = struct
        fun inv_order _ i = i
      end
    end
  in
    structure IterPyrSearch = IterSearchFn(P)
  end

  local
    structure P =
    struct
      structure Search = SBSearch
      structure Opts = struct
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
      end
    end
  in
    structure IterSBSearch = IterSearchFn(P)
  end

  structure RotPyrSearch = RotSearchFn(IterPyrSearch)
  structure RotSBSearch = RotSearchFn(IterSBSearch)

end
