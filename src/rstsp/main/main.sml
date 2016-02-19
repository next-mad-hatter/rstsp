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
    structure CostCheck = TSPCostFn(D)
  in
    fun singlerun (data, opts, search, toStr, toVec, method) =
      if D.getDim data < 0w2 then print "Empty problem.\n"
      else
        let
          val (verbose, _, pyramidal, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, in_tour, out_tour, _) = opts
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
          val _ = if out_tour = NONE then () else TourWriter.writeTourFile 0w1 (valOf out_tour) (toVec sol)
        in
          print ("        Trampoline:  " ^ (if in_tour = NONE then "none" else valOf in_tour) ^ "\n");
          print ("          Solution:  " ^ (if isSome out_tour then ("written to " ^ valOf out_tour) else toStr sol) ^ "\n");
          print ("      Problem size:  " ^ (U.wordToString size) ^ "\n");
          print ("            Method:  " ^ method ^ "\n");
          print ("SB Node size limit:  " ^ (if pyramidal orelse max_node_size = NONE then "none" else (U.wordToString o valOf) max_node_size) ^ "\n");
          print ("  Iterations limit:  " ^ (if max_iters = NONE then "none" else (IntInf.toString o valOf) max_iters) ^ "\n");
          print ("   Stale threshold:  " ^ (if stale_thresh = NONE then "none" else (IntInf.toString o valOf) stale_thresh) ^ "\n");
          print ("  Min permutations:  " ^ (if min_rot = NONE then "none" else (U.wordToString o valOf) min_rot) ^ "\n");
          print ("  Max permutations:  " ^ (if max_rot = NONE then "all" else (U.wordToString o valOf) max_rot) ^ "\n");
          print ("         Max flips:  " ^ (if max_flips = NONE then "unlimited" else (IntInf.toString o valOf) max_flips) ^ "\n");
          print ("         CPU timer:  " ^ cpu ^ " ms\n");
          print ("        Real timer:  " ^ real ^ " ms\n");
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
               val len_val = D.Num.compare(sol_len, CostCheck.tourCost data sol_vec) = EQUAL
               val sol_val = TSPUtils.validTour size sol_vec
             in
                print ("    Solution valid:  " ^ (if sol_val andalso len_val then "yes" else "NO!") ^ "\n")
             end
          );
          print ("         Tour cost:  " ^ (D.Num.toString sol_len) ^ "\n");
          TextIO.flushOut TextIO.stdOut;
          ()
        end
      end

  local
    structure S : SEARCHES = TrampSearches(DefaultSearches(D.Num))
  in
    fun run opts data =
    let
      val (verbose, log, pyramidal, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, in_tour, _, _) = opts
      val init_tour = if isSome in_tour then TourReader.readTourFile (valOf in_tour) else NONE
    in
        case (pyramidal,
              isSome max_iters andalso valOf max_iters = IntInf.fromInt 1 andalso max_rot = SOME 0w0,
              isSome min_rot,
              max_flips = SOME (IntInf.fromInt 0)
             ) of
          (true,true,_,_) => singlerun (data, opts,
                            fn (s,d) => S.PyrSearch.search s d log verbose (init_tour, ()),
                            S.PyrSearch.tourToString,
                            S.PyrSearch.tourToVector,
                            "single pyramidal")
        | (false,true,_,_) => singlerun (data, opts,
                             fn (s,d) => S.SBSearch.search s d log verbose (init_tour, max_node_size),
                             S.SBSearch.tourToString,
                             S.SBSearch.tourToVector,
                             "single str. balanced")
        | (true,_,false,_) => singlerun (data, opts,
                               fn (s,d) => S.IterRotPyrSearch.search s d log verbose (init_tour, (max_iters, stale_thresh, (max_rot, 0w0, ()))),
                               S.IterRotPyrSearch.tourToString,
                               S.IterRotPyrSearch.tourToVector,
                               "permuting pyramidal")
        | (true,_,true,_) => singlerun (data, opts,
                                fn (s,d) => S.AdPyrSearch.search s d log verbose (init_tour, (max_iters, stale_thresh, valOf min_rot, max_rot, ())),
                                S.AdPyrSearch.tourToString,
                                S.AdPyrSearch.tourToVector,
                                "adaptive pyramidal")
        | (_,_,false,true) => singlerun (data, opts,
                                  fn (s,d) => S.IterRotSBSearch.search s d log verbose (init_tour, (max_iters, stale_thresh, (max_rot, 0w0, max_node_size))),
                                  S.IterRotSBSearch.tourToString,
                                  S.IterRotSBSearch.tourToVector,
                                  "permuting str. balanced")
        | (_,_,true,true) => singlerun (data, opts,
                                  fn (s,d) => S.AdSBSearch.search s d log verbose (init_tour, (max_iters, stale_thresh, valOf min_rot, max_rot, max_node_size)),
                                  S.AdSBSearch.tourToString,
                                  S.AdSBSearch.tourToVector,
                                  "adaptive str. balanced")
        | (_,_,_,false) => singlerun (data, opts,
                                  fn (s,d) => S.FlipFlopSearch.search s d log verbose (init_tour, (
                                     max_flips, SOME 1,
                                     ((
                                        case (if isSome max_rot then SOME (IntInf.max (IntInf.fromInt 1,(Word.toLargeInt o valOf) max_rot)) else NONE, max_iters) of
                                          (NONE, m) => m
                                        | (m, NONE) => m
                                        | (SOME a, SOME b) => SOME (IntInf.max (a,b))
                                      ), stale_thresh, ()),
                                     (max_iters, stale_thresh, if isSome min_rot then valOf min_rot else 0w0, max_rot, max_node_size)
                                  )),
                                  S.FlipFlopSearch.tourToString,
                                  S.FlipFlopSearch.tourToVector,
                                  "flipflop")
    end
  end

end


functor MainFn(S : SETTINGS) : MAIN =
struct

  structure U = Utils

  datatype tsplib_inst = datatype TsplibReader.tsplib_inst

  local
    structure ProcExpl = ProcessFn(NatDist)
    (*
     * TODO: add float/int distance choice
    structure ProcEucl2D = ProcessFn(Eucl2DDist)
     *)
    structure ProcEucl2D = ProcessFn(Eucl2DNNDist)
    structure ProcEucl2DCeil = ProcessFn(Eucl2DCeilDist)
  in
    fun processFile opts file =
    let
      val _ = print ("===================================================\n")
      val _ = print (" Processing " ^ file ^ ":\n")
      val _ = print ("===================================================\n")
      val inst = (SOME (TsplibReader.readTSPFile file))
                   handle Fail msg => (U.printErr ("  Error: " ^ msg ^ "\n"); NONE)
                        | _ => (U.printErr ("  Could not read file \"" ^ file ^ "\" .\n"); NONE)
    in
      (
        case inst of
          NONE => ()
        | SOME (EXPLICIT_INSTANCE data) => ProcExpl.run opts data
        | SOME (EUCLIDEAN_2D_INSTANCE data) => ProcEucl2D.run opts data
        | SOME (EUCLIDEAN_2D_CEIL_INSTANCE data) => ProcEucl2DCeil.run opts data
      )
        handle Fail msg => U.printErr ("  Error: " ^ msg ^ "\n")
    end
  end

  fun main () =
  let
    val opts = Options.reader S.getCmdName S.getArgs ()
    val _ = case isSome opts of
              false => OS.Process.exit OS.Process.failure
            | _ => ()
    val (_, _, _, _, max_iters, stale_thresh, _, _, _, _, _, files) = valOf opts
    val _ = case (max_iters, stale_thresh) of
              (NONE, NONE) =>
              ( U.printErr
                "WARNING: neither iterations limit nor stale threshold is set.  This will diverge.\n";
                OS.Process.exit OS.Process.failure
              )
            | _ => ()
  in
    List.app (processFile (valOf opts)) files
  end

end
