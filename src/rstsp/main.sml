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

  fun read file =
    (DistMat.readDistFile file)
      handle Fail msg => (print ("  Format Error: " ^ msg ^ "\n"); NONE)
           | _ => (print ("  Could not read file \"" ^ file ^ "\" .\n"); NONE)

  fun main_iter (search, to_vec, to_str, (verbose, pyramidal, max_ints, max_iters)) file = let
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
        val sol = (valOf sol') ()
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
        print (" Node length limit:  " ^ (if pyramidal orelse max_ints = NONE then "none" else (wordToString o valOf) max_ints) ^ "\n");
        print ("        Iterations:  " ^ (if max_iters = NONE then "none" else (IntInf.toString o valOf) max_iters) ^ "\n");
        if verbose andalso isSome max_iters andalso valOf max_iters = IntInf.fromInt 1 then (
          let
            val (nn, nk, hs) = valOf stats
          in
            print ("        Node types:  " ^ (wordToString nk) ^ "\n");
            print ("        Store size:  " ^ (wordToString nn) ^ "\n");
            print ("       Node hashes:  " ^ (wordToString hs) ^ "\n");
            ()
          end
        ) else ();
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
    val (verbose, log, pyramidal, max_ints, max_iters, files) = valOf opts
    (*
    val _ =
      case isSome log of
        true => ( case OS.FileSys.access (valOf log, []) of
                    true => (printErr "Log file exists.\n"; OS.Process.exit OS.Process.failure)
                  | _ => ()
                )
      | _ => ()
     *)
  in
    case (pyramidal, isSome max_iters andalso valOf max_iters = IntInf.fromInt 1) of
      (true, true) =>
        List.app (main_iter (
            (fn (size,dist) => PyrSearch.search size dist log verbose ()),
            PyrSearch.toVector,
            PyrSearch.toString,
            (verbose, pyramidal, max_ints, max_iters)
          )) files
    | (false, true) =>
        List.app (main_iter (
            (fn (size,dist) => SBSearch.search size dist log verbose max_ints),
            SBSearch.toVector,
            SBSearch.toString,
            (verbose, pyramidal, max_ints, max_iters)
          )) files
    | (true, false) =>
        List.app (main_iter (
            (fn (size,dist) => LocalPyrSearch.search size dist log verbose (max_iters,())),
            LocalPyrSearch.toVector,
            LocalPyrSearch.toString,
            (verbose, pyramidal, max_ints, max_iters)
          )) files
    | (false, false) =>
        List.app (main_iter (
            (fn (size,dist) => LocalSBSearch.search size dist log verbose (max_iters, max_ints)),
            LocalSBSearch.toVector,
            LocalSBSearch.toString,
            (verbose, pyramidal, max_ints, max_iters)
          )) files
  end

end

