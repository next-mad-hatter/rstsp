(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Common functionality of rstsp -- entry points and other things
 * specific to SML implementations will go into their respective
 * toplevel files.
 *)

signature MAIN = sig
  val main: unit -> unit
end


(**
 * The part of main which depends on distance type.
 *)
functor ProcessFn(D : DISTANCE) =
struct

  structure U = Utils

  local
    structure LenCheck = TSPLengthFn(D)
  in
    fun singlerun (data, opts, search, toStr, toVec) =
      if D.getDim data < 0w2 then print "Empty problem.\n"
      else
        let
          val (verbose, _, pyramidal, max_node_size, max_iters, stale_thresh, _, _) = opts
          val dist = D.getDist data
          val size = D.getDim data
          val cpu_timer = Timer.startCPUTimer ()
          val real_timer = Timer.startRealTimer ()
          val (sol', stats) = (search (size,dist) ())
          val (sol_len, sol_fn) = valOf sol'
          val sol = sol_fn ()
          val real_stop = Timer.checkRealTimer real_timer
          val cpu_stop = Timer.checkCPUTimer cpu_timer
          val cpu = (IntInf.toString o (foldl op+ 0) o (map Time.toMilliseconds)) [#sys cpu_stop, #usr cpu_stop]
          val real = (IntInf.toString o Time.toMilliseconds) real_stop
        in
          print ("      Problem size:  " ^ (U.wordToString size) ^ "\n");
          print ("         Algorithm:  " ^ (if pyramidal then "pyramidal" else "balanced") ^ "\n");
          print ("   Node size limit:  " ^ (if pyramidal orelse max_node_size = NONE then "none" else (U.wordToString o valOf) max_node_size) ^ "\n");
          print ("  Iterations limit:  " ^ (if max_iters = NONE then "none" else (IntInf.toString o valOf) max_iters) ^ "\n");
          print ("   Stale threshold:  " ^ (if stale_thresh = NONE then "none" else (IntInf.toString o valOf) stale_thresh) ^ "\n");
          (case stats of
            NONE => ()
          | SOME (nn, nk, hs) => (
              print ("        Node types:  " ^ (U.wordToString nk) ^ "\n");
              print ("        Store size:  " ^ (U.wordToString nn) ^ "\n");
              print ("       Node hashes:  " ^ (U.wordToString hs) ^ "\n")
              ));
          (case verbose of
             false => ()
           | _ =>
             let
               val sol_vec = toVec sol
               val len_val = D.Num.compare(sol_len, LenCheck.tourLength data sol_vec) = EQUAL
               val sol_val = TSPUtils.validTour size sol_vec
             in
                print ("    Solution valid:  " ^ (if sol_val andalso len_val then "yes" else "NO!") ^ "\n")
             end
          );
          print ("         CPU timer:  " ^ cpu ^ " ms\n");
          print ("        Real timer:  " ^ real ^ " ms\n");
          print ("          Solution:  " ^ (toStr sol) ^ "\n");
          print ("       Tour Length:  " ^ (D.Num.toString sol_len) ^ "\n");
          TextIO.flushOut TextIO.stdOut;
          ()
        end
      end

  local
    structure S : SEARCHES = DefaultSearches(D.Num)
  in
    fun run opts data =
    let
      val (verbose, log, pyramidal, max_node_size, max_iters, stale_thresh, max_rot, _) = opts
    in
        case (pyramidal,
              isSome max_iters andalso valOf max_iters = IntInf.fromInt 1 andalso max_rot = SOME 0w0
             ) of
          (true, true) => singlerun (data, opts,
                            fn (s,d) => S.PyrSearch.search s d log verbose (),
                            S.PyrSearch.tourToString,
                            S.PyrSearch.tourToVector)
        | (false, true) => singlerun (data, opts,
                             fn (s,d) => S.SBSearch.search s d log verbose max_node_size,
                             S.SBSearch.tourToString,
                             S.SBSearch.tourToVector)
        | (true, false) => singlerun (data, opts,
                             fn (s,d) => S.RotPyrSearch.search s d log verbose (max_rot, (max_iters, stale_thresh, ())),
                             S.RotPyrSearch.tourToString,
                             S.RotPyrSearch.tourToVector)
        | (false, false) => singlerun (data, opts,
                              fn (s,d) => S.RotSBSearch.search s d log verbose (max_rot, (max_iters, stale_thresh, max_node_size)),
                              S.RotSBSearch.tourToString,
                              S.RotSBSearch.tourToVector)
    end
  end

end


functor MainFn(S : SETTINGS) : MAIN =
struct

  structure U = Utils

  datatype tsplib_inst = datatype TsplibReader.tsplib_inst

  local
    structure ProcExpl = ProcessFn(NatDist)
    structure ProcEucl2D = ProcessFn(Eucl2DDist)
  in
    fun processFile opts file =
    let
      val _ = print ("===================================================\n")
      val _ = print (" Processing " ^ file ^ ":\n")
      val _ = print ("===================================================\n")
      val inst = (SOME (TsplibReader.readTSPFile file))
                   handle Fail msg => (U.printErr ("  Input Error: " ^ msg ^ "\n"); NONE)
                        | _ => (U.printErr ("  Could not read file \"" ^ file ^ "\" .\n"); NONE)
    in
      case inst of
        NONE => ()
      | SOME (EXPLICIT_INSTANCE data) => ProcExpl.run opts data
      | SOME (EUCLIDEAN_2D_INSTANCE data) => ProcEucl2D.run opts data
    end
  end

  fun main () =
  let
    val opts = Options.reader S.getCmdName S.getArgs ()
    val _ = case isSome opts of
              false => OS.Process.exit OS.Process.failure
            | _ => ()
    val (_, _, _, _, max_iters, stale_thresh, _, files) = valOf opts
    val _ = case (max_iters, stale_thresh) of
              (NONE, NONE) => U.printErr
                "WARNING: neither iterations limit nor stale threshold is set.  This might diverge.\n"
            | _ => ()
  in
    List.app (processFile (valOf opts)) files
  end

end
