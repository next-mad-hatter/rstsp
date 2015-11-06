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

  fun read file =
    (DistMat.readDistFile file)
      handle Fail msg => (print ("  Format Error: " ^ msg ^ "\n"); NONE)
           | _ => (print ("  Could not read file \"" ^ file ^ "\" .\n"); NONE)

  fun main_iter (search, to_vec, to_str, (verbose, pyramidal, max_ints)) file = let
    val _ = print ("===================================================\n")
    val _ = print ("Processing " ^ file ^ ":\n")
    val _ = print ("===================================================\n")
    val d = read file
  in
    if isSome d andalso (DistMat.length o valOf) d > 1 then
      let
        val dist = DistMat.getDist (valOf d)
        val size = Word.div(wordSqrt(0w1+0w8*(Word.fromInt (DistMat.length (valOf d))))-0w1,0w2)
        val timer = Timer.totalCPUTimer ()
        val res = search (size,dist) ()
        val sol = valOf (#1 res)
        val stop = Timer.checkCPUTimer timer
        val sys = (IntInf.toString o Time.toMilliseconds o #sys) stop
        val usr = (IntInf.toString o Time.toMilliseconds o #usr) stop
        val total = IntInf.toString (Time.toSeconds (#usr stop) + Time.toSeconds (#sys stop))
        val sol_vec = to_vec sol
        val sol_str = to_str sol
        val sol_len = tourLength dist sol_vec
        val sol_val = validTour size sol_vec
      in
        print ("   Solution:  " ^ sol_str ^ "\n");
        print ("      Valid:  " ^ (if sol_val then "yes" else "NO!") ^ "\n");
        print ("     Length:  " ^ (wordToString sol_len) ^ "\n");
        if verbose then (
          let
            val (nn, nk) = valOf (#2 res)
          in
            print ("     Search:  " ^ (if pyramidal then "pyramidal" else "balanced") ^ "\n");
            print ("      Limit:  " ^ (if pyramidal orelse max_ints = NONE then "none" else (wordToString o valOf) max_ints) ^ "\n");
            print (" Store size:  " ^ (wordToString nn) ^ "\n");
            print (" Node types:  " ^ (wordToString nk) ^ "\n");
            print ("        Sys:  " ^ sys ^ "ms\n");
            print ("        Usr:  " ^ usr ^ "ms\n");
            ()
          end
        ) else ();
        print ("       Time:  " ^ total ^ "s\n");
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
    val (verbose, log, pyramidal, max_ints, files) = valOf opts
    val _ =
      case isSome log of
        true => ( case OS.FileSys.access (valOf log, []) of
                    true => (printErr "Log file exists.\n"; OS.Process.exit OS.Process.failure)
                  | _ => ()
                )
      | _ => ()
  in
    if pyramidal then
        List.app (main_iter (
            (fn (size,dist) => PyrSearch.search size dist log verbose ()),
            PyrSearch.Tour.toVector,
            PyrSearch.Tour.toString,
            (verbose, pyramidal, max_ints)
          )) files
      else
        List.app (main_iter (
            (fn (size,dist) => SBSearch.search size dist log verbose max_ints),
            SBSearch.Tour.toVector,
            SBSearch.Tour.toString,
            (verbose, pyramidal, max_ints)
          )) files
  end
end

