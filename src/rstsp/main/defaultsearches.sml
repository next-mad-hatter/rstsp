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

  (* inverse of Supnick permutation *)
  fun sb_shuffle size i = case Word.mod(i,0w2) of
                            0w0 => Word.div (size-i-0w1,0w2)
                          | _   => Word.div (size+i,0w2)

  (* Supnick permutation *)
  fun sb_unshuffle size i =
  let
    val m = Word.div (size-0w1,0w2)
  in
    case i <= m of
      true => 0w2*(m-i)
    | _   => 0w2*(i-m-0w1)+0w1
  end

  (* inverse of "interleaved Supnick" permutation *)
  fun inter_shuffle n i =
  let
    val m = Word.div (n+0w1,0w2)
  in
    if i < m then 0w2 * (sb_shuffle m i)
             else 0w1 + 0w2 * (sb_shuffle (n-m) (i-m))
  end

  (* in case we want the back transformation: "iterleaved Supnick" permutation *)
  fun inter_unshuffle size i =
  let
    val m = Word.div (size+0w1,0w2)
  in
    case Word.mod (i,0w2) = 0w0 of
      true => sb_unshuffle m (Word.div (i,0w2))
    | _ => m + sb_unshuffle (size-m) (Word.div (i-0w1,0w2))
  end

  fun id _ i = i

  fun cycle size n = fn i => Word.mod (n + i + 0w1, size)

  structure RotPyrSearch = RotSearchFn(
    struct
      structure Search = PyrSearch
      (* we only have symmetric instances for now *)
      (* fun max_perm size = size-0w1 *)
      fun max_perm size = Word.div (size+0w1,0w2)
      val permute = cycle
    end
  )

  (**
   * Ad s.b. ILS:
   *
   * as of now, normal interleaved supnick transform seems
   * to perform somewhat better than reversed version,
   * but, interestingly, larger node sizes yield better results with
   * inverted transform.
   *)
  structure RotSBSearch = RotSearchFn(
    struct
      structure Search = SBSearch
      fun max_perm size = 0w2 * Word.div (size+0w1,0w2)
      fun permute size n =
        if n < Word.div(size+0w1,0w2)
                    then (sb_unshuffle size) o (cycle size n) o (sb_shuffle size)
                    else (inter_unshuffle size) o (cycle size (n-Word.div (size+0w1,0w2))) o (inter_shuffle size)
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

  structure AdPyrSearch = AdSearchFn(
    struct
      structure Search = PyrSearch
      val inv_order = id
      (* we only have symmetric instances for now *)
      (* fun max_perm size = size-0w1 *)
      fun max_perm size = Word.div(size,0w2)
      val permute = cycle
      fun increase rot = 0w1 + 0w2*rot
    end)

  structure AdSBSearch = AdSearchFn(
    struct
      structure Search = SBSearch
      val inv_order = sb_shuffle
      fun max_perm size = 0w2 * Word.div (size+0w1,0w2)
      fun permute size n =
        if n < Word.div(size+0w1,0w2)
                    then (sb_unshuffle size) o (cycle size n) o (sb_shuffle size)
                    else (inter_unshuffle size) o (cycle size (n-Word.div (size+0w1,0w2))) o (inter_shuffle size)
      fun increase rot = 0w1 + (Word.fromInt o Real.ceil) (((Real.fromInt o Word.toInt) rot) * 1.21)
    end)

  structure FlipFlopSearch = FlipFlopSearchFn(
    struct
      structure Search' = IterPyrSearch
      val inv_order' = id
      structure Search'' = AdSBSearch
      val inv_order'' = sb_shuffle
    end)

end
