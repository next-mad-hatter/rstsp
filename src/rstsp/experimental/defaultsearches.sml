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

  fun id _ i = i

  fun cycle size n = fn i => Word.mod (n + i, size)

  fun sb_shuffle size i =
  let
    val size' = Word.toInt size
    val i' = Word.toInt i
    val j = case Int.mod(i',2) of
              0 => Real.floor (Real.fromInt (size'-i'-1) / 2.0)
            | _ => Real.ceil  (Real.fromInt (size'+i'-1) / 2.0)
  in
    Word.fromInt j
  end

  structure RotPyrSearch = RotSearchFn(
    struct
      structure Search = PyrSearch
      val perm = cycle
      fun max_perm size = size-0w1
    end
  )

  structure RotSBSearch = RotSearchFn(
    struct
      structure Search = SBSearch
      fun perm size n =
      let
        val x = Word.mod(n,0w3)
        val y = Word.div(n,0w3)
        fun f1 i = if x = 0w0 then i else size-0w1-i
        val f2 = if x = 0w1 then fn i => i else sb_shuffle size
      in
        (cycle size y) o f1 o f2
      end
      fun max_perm size = 0w2*(size-0w1)
    end
  )

  structure IterPyrSearch = IterSearchFn(
    struct
      structure Search = PyrSearch
      val inv_order = id
    end)

  structure IterSBSearch = IterSearchFn(
    struct
      structure Search = SBSearch
      val inv_order = sb_shuffle
    end)

  structure IterRotPyrSearch = IterSearchFn(
    struct
      structure Search = RotPyrSearch
      val inv_order = id
    end)

  structure IterRotSBSearch = IterSearchFn(
    struct
      structure Search = RotSBSearch
      val inv_order = sb_shuffle
    end)

end
