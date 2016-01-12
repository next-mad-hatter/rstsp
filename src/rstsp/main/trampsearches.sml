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
functor TrampSearches(S : SEARCHES) : SEARCHES =
struct

  fun sb_shuffle size i = case Word.mod(i,0w2) of
                            0w0 => Word.div (size-i-0w1,0w2)
                          | _   => Word.div (size+i,0w2)

  fun id _ i = i

  structure PyrSearch = TrampSearchFn(
    struct
      structure Search = S.PyrSearch
      val shuffle = id
    end
  )

  structure SBSearch = TrampSearchFn(
    struct
      structure Search = S.SBSearch
      val shuffle = sb_shuffle
    end
  )

  structure RotPyrSearch = TrampSearchFn(
    struct
      structure Search = S.RotPyrSearch
      val shuffle = id
    end
  )

  structure RotSBSearch = TrampSearchFn(
    struct
      structure Search = S.RotSBSearch
      val shuffle = sb_shuffle
    end
  )

  structure IterPyrSearch = TrampSearchFn(
    struct
      structure Search = S.IterPyrSearch
      val shuffle = id
    end
  )

  structure IterSBSearch = TrampSearchFn(
    struct
      structure Search = S.IterSBSearch
      val shuffle = sb_shuffle
    end
  )

  structure IterRotPyrSearch = TrampSearchFn(
    struct
      structure Search = S.IterRotPyrSearch
      val shuffle = id
    end
  )

  structure IterRotSBSearch = TrampSearchFn(
    struct
      structure Search = S.IterRotSBSearch
      val shuffle = sb_shuffle
    end
  )

  structure AdPyrSearch = TrampSearchFn(
    struct
      structure Search = S.AdPyrSearch
      val shuffle = id
    end
  )

  structure AdSBSearch = TrampSearchFn(
    struct
      structure Search = S.AdSBSearch
      val shuffle = sb_shuffle
    end
  )

  structure FlipFlopSearch = TrampSearchFn(
    struct
      structure Search = S.FlipFlopSearch
      val shuffle = sb_shuffle
    end
  )

end
