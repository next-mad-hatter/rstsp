(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature MAIN = sig
  val main: unit -> unit
end

functor MainFn(Settings: SETTINGS) : MAIN =
struct

  open Utils
  open Settings

  local
    structure P =
    struct
      structure Search = PyrSearch
      structure Opts = struct
        fun inv_order _ i = i
      end
    end
  in
    structure LocalPyrSearch = LocalSearchFn(P)
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
    structure LocalSBSearch = LocalSearchFn(P)
  end

  structure RotPyrSearch = RotSearchFn(LocalPyrSearch)
  structure RotSBSearch = RotSearchFn(LocalSBSearch)

  fun read file =
    (DistMat.readDistFile file)
      handle Fail msg => (print ("  Format Error: " ^ msg ^ "\n"); NONE)
           | _ => (print ("  Could not read file \"" ^ file ^ "\" .\n"); NONE)

  fun main_iter (search, to_vec, to_str, (pyramidal, max_node_size, max_iters, stale_thresh)) file = let
    val _ = print ("===================================================\n")
    val _ = print ("Processing " ^ file ^ ":\n")
    val _ = print ("===================================================\n")
    val d = read file
  in
    if isSome d andalso (DistMat.length o valOf) d > 1 then
      let
        val dist = DistMat.getDist (valOf d)
        val size = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (DistMat.length (valOf d))))-0w1,0w2)
        val cpu_timer = Timer.startCPUTimer ()
        val real_timer = Timer.startRealTimer ()
        val (sol', stats) = (search (size,dist) ())
        val sol = ((#2 o valOf) sol') ()
        val real_stop = Timer.checkRealTimer real_timer
        val cpu_stop = Timer.checkCPUTimer cpu_timer
        val cpu = (IntInf.toString o (foldl op+ 0) o (map Time.toMilliseconds))
                    [#sys cpu_stop, #usr cpu_stop]
        val real = (IntInf.toString o Time.toMilliseconds) real_stop
        val sol_vec = to_vec sol
        val sol_len = tourLength dist sol_vec
        val sol_val = validTour size sol_vec
        val sol_str = to_str sol
      in
        print ("      Problem size:  " ^ (wordToString size) ^ "\n");
        print ("         Algorithm:  " ^ (if pyramidal then "pyramidal" else "balanced") ^ "\n");
        print (" Node length limit:  " ^ (if pyramidal orelse max_node_size = NONE then "none" else (wordToString o valOf) max_node_size) ^ "\n");
        print ("  Iterations limit:  " ^ (if max_iters = NONE then "none" else (IntInf.toString o valOf) max_iters) ^ "\n");
        print ("   Stale threshold:  " ^ (if stale_thresh = NONE then "none" else (IntInf.toString o valOf) stale_thresh) ^ "\n");
        (case stats of
          NONE => ()
        | SOME (nn, nk, hs) => (
            print ("        Node types:  " ^ (wordToString nk) ^ "\n");
            print ("        Store size:  " ^ (wordToString nn) ^ "\n");
            print ("       Node hashes:  " ^ (wordToString hs) ^ "\n")
            ));
        print ("         CPU timer:  " ^ cpu ^ " ms\n");
        print ("        Real timer:  " ^ real ^ " ms\n");
        print ("          Solution:  " ^ sol_str ^ "\n");
        print ("             Valid:  " ^ (if sol_val then "yes" else "NO!") ^ "\n");
        print ("       Tour Length:  " ^ (wordToString sol_len) ^ "\n");
        ()
      end
    else print " Empty problem.\n"
  end

  fun main () =
  let
    val opts = Options.reader getCmdName getArgs ()
    val _ = case isSome opts of
              false => OS.Process.exit OS.Process.failure
            | _ => ()
    val (verbose, log, pyramidal, max_node_size, max_iters, stale_thresh, max_rot, files) = valOf opts
    val _ = case (max_iters, stale_thresh) of
              (NONE, NONE) => printErr "WARNING: neither iterations limit nor stale threshold is set.  This might diverge.\n"
            | _ => ()
  in
    case (pyramidal,
          isSome max_iters andalso valOf max_iters = IntInf.fromInt 1 andalso max_rot = SOME 0w0
         ) of
      (true, true) =>
        List.app (main_iter (
            (fn (size,dist) => PyrSearch.search size dist log verbose ()),
            PyrSearch.toVector,
            PyrSearch.toString,
            (pyramidal, max_node_size, max_iters, stale_thresh)
          )) files
    | (false, true) =>
        List.app (main_iter (
            (fn (size,dist) => SBSearch.search size dist log verbose max_node_size),
            SBSearch.toVector,
            SBSearch.toString,
            (pyramidal, max_node_size, max_iters, stale_thresh)
          )) files
    | (true, false) =>
        List.app (main_iter (
            (fn (size,dist) => RotPyrSearch.search size dist log verbose (max_rot, (max_iters, stale_thresh, ()))),
            RotPyrSearch.toVector,
            RotPyrSearch.toString,
            (pyramidal, max_node_size, max_iters, stale_thresh)
          )) files
    | (false, false) =>
        List.app (main_iter (
            (fn (size,dist) => RotSBSearch.search size dist log verbose (max_rot, (max_iters, stale_thresh, max_node_size))),
            RotSBSearch.toVector,
            RotSBSearch.toString,
            (pyramidal, max_node_size, max_iters, stale_thresh)
          )) files
  end

end

