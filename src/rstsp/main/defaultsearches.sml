(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * These are used in main and can be implementation-specific
 * (e.g. threaded versions for Poly/ML).
 *)
functor DefaultSearches(N : NUMERIC) : SEARCHES =
struct

  structure PyrSearch = SimpleSearchFn(PyrGraph(N))

  structure SBSearch = SimpleSearchFn(SBGraph(N))

  fun id _ i = i

  fun cycle size n = fn i => Word.mod (n + i, size)

  fun sb_shuffle size i =
    case Word.mod(i,0w2) of
      0w0 => Word.div (size-i-0w1,0w2)
    | _   => Word.div (size+i,0w2)

  structure RotPyrSearch = RotSearchFn(
    struct
      structure Search = PyrSearch
      fun max_perm size = size-0w1
      val perm = cycle
    end
  )

  structure RotSBSearch = RotSearchFn(
    struct
      fun max_perm size = 0w2*(size-0w1)
      structure Search = SBSearch
      fun perm size n =
      let
        val x = Word.mod(n,0w2)
        val y = Word.div(n,0w2)
        fun f1 i = if x = 0w0 then i else size-0w1-i
      in
        (cycle size y) o f1 o (sb_shuffle size)
      end
      (*
      fun max_perm size = 0w3*(size-0w1)
      fun perm size n =
      let
        val x = Word.mod(n,0w3)
        val y = Word.div(n,0w3)
        fun f1 i = if x = 0w0 then i else size-0w1-i
        val f2 = if x = 0w1 then fn i => i else sb_shuffle size
      in
        (cycle size y) o f1 o f2
      end
      *)
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
