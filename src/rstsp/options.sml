(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature OPTIONS =
sig

  (*
   * Returns:
   *    verbose: bool
   *    dot file: string option
   *    pyramidal: bool
   *    max ints: word option
   *    iters: IntInf.int option
   *    stale: IntInf.int option
   *    max rot: word option
   *    files: string list
   *   option (when wrong args/empty files list).
   *)
  val reader: (unit -> string) -> (unit -> string list) ->
    unit -> (bool * string option * bool * word option * IntInf.int option * IntInf.int option * word option * string list) option

end

structure Options : OPTIONS =
struct

  open Utils

  exception Usage

  datatype expect = ANY | ALGO | LOG | MAX_INTS | MAX_ITERS | STALE_THRESH | MAX_ROT

  fun expect "-t" = ALGO
    | expect "--type" = ALGO
    | expect "-l" = LOG
    | expect "--log" = LOG
    | expect "-m" = MAX_INTS
    | expect "--max" = MAX_INTS
    | expect "-i" = MAX_ITERS
    | expect "--iter" = MAX_ITERS
    | expect "-j" = STALE_THRESH
    | expect "--stale" = STALE_THRESH
    | expect "-r" = MAX_ROT
    | expect "--rot" = MAX_ROT
    | expect _ = ANY

  fun printUsage cmd_name = (
    print "Usage:\n";
    print ("  " ^ cmd_name ^ " -h|--help\n");
    print ("  " ^ cmd_name ^ " [options] file(s)\n");
    print "where options are any of:\n";
    print "\n";
    print "    -h|--help      :  print this message and quit\n";
    print "\n";
    print "    -t|--type p|b  :  pyramidal / balanced search\n";
    print "                      (default: balanced)\n";
    print "\n";
    print "    -m|--max width :  maximum node width for balanced search\n";
    print "                      (zero for unlimited, default: none)\n";
    print "\n";
    print "    -i|--iter num  :  maximum number of iterations in local search\n";
    print "                      (zero for unlimited)\n";
    print "                      (default: 1, i.e. no local search)\n";
    print "\n";
    print "    -j|--stale num :  maximum number of stale iterations in local search\n";
    print "                      (zero for unlimited, default: 10)\n";
    print "\n";
    print "  -r|--rot all|num :  maximum number of rotations in local search\n";
    print "                      (\"all\" for all rotations, default: 0)\n";
    print "\n";
    print "    -l|--log file  :  if specified, traversal trace (in dot format)\n";
    print "                      will be written to the file\n";
    print "\n";
    print "    -v|--verbose   :  print additional info (such as store statistics)\n";
    print "\n";
    ()
    )

  fun read cmd_name args =
  let

    fun read_next expects opts args =
    let
      val (verbose, log, pyr, max_ints, max_iters, stale_thresh, max_rot, files) = opts
    in
      case expects of
        ALGO =>
        let
          val new_opts =
            case (String.isPrefix (hd args) "pyramidal",
                  String.isPrefix (hd args) "balanced") of
              (true,_) => (verbose, log, true, max_ints, max_iters, stale_thresh, max_rot, files)
            | (_,true) => (verbose, log, false, max_ints, max_iters, stale_thresh, max_rot, files)
            | _ => raise Fail ("unknown algorithm: " ^ hd args)
        in
          read_next ANY new_opts (tl args)
        end
      | LOG =>
        let
          val new_opts =
            case log of
              NONE => (verbose, SOME (hd args), pyr, max_ints, max_iters, stale_thresh, max_rot, files)
            | SOME l =>
                case l = hd args of
                  true => opts
                | _ => raise Fail ("multiple log files requested")
        in
          read_next ANY new_opts (tl args)
        end
      | MAX_INTS =>
        let
          val new_opts =
            case wordFromString (hd args) of
              SOME 0w0 => (verbose, log, pyr, NONE, max_iters, stale_thresh, max_rot, files)
            | SOME m => (verbose, log, pyr, SOME m, max_iters, stale_thresh, max_rot, files)
            | _ => raise Fail ("invalid maximum intervals number")
        in
          read_next ANY new_opts (tl args)
        end
      | MAX_ITERS =>
        let
          val new_opts =
            case IntInf.fromString (hd args) of
              SOME m =>
                (
                  case m = IntInf.fromInt 0 of
                    true => (verbose, log, pyr, max_ints, NONE, stale_thresh, max_rot, files)
                  | false => (verbose, log, pyr, max_ints, SOME m, stale_thresh, max_rot, files)
                )
            | NONE => raise Fail ("invalid maximum intervals number")
        in
          read_next ANY new_opts (tl args)
        end
      | STALE_THRESH =>
        let
          val new_opts =
            case IntInf.fromString (hd args) of
              SOME m =>
                (
                  case m = IntInf.fromInt 0 of
                    true => (verbose, log, pyr, max_ints, max_iters, NONE, max_rot, files)
                  | false => (verbose, log, pyr, max_ints, max_iters, SOME m, max_rot, files)
                )
            | NONE => raise Fail ("invalid stale intervals number")
        in
          read_next ANY new_opts (tl args)
        end



      | MAX_ROT =>
        let
          val new_opts =
            case hd args of
              "none" => (verbose, log, pyr, max_ints, max_iters, stale_thresh, NONE, files)
            | str => case wordFromString str of
                       SOME m => (verbose, log, pyr, max_ints, max_iters, stale_thresh, SOME m, files)
                     | NONE => raise Fail ("invalid rotations number")
        in
          read_next ANY new_opts (tl args)
        end



      | ANY =>
          case args of
            [] => opts
          | ["-h"] => (printUsage cmd_name; OS.Process.exit OS.Process.success)
          | ["--help"] => (printUsage cmd_name; OS.Process.exit OS.Process.success)
          | _ =>
            let
              val (verbose, log, pyr, max_ints, max_iters, stale_thresh, max_rot, files) = opts
            in
              case (expect (hd args), hd args) of
                (ALGO,_) => read_next ALGO opts (tl args)
              | (LOG,_) => read_next LOG opts (tl args)
              | (MAX_INTS,_) => read_next MAX_INTS opts (tl args)
              | (MAX_ITERS,_) => read_next MAX_ITERS opts (tl args)
              | (STALE_THRESH,_) => read_next STALE_THRESH opts (tl args)
              | (MAX_ROT,_) => read_next MAX_ROT opts (tl args)
              | (_,"--") => (verbose, log, pyr, max_ints, max_iters, stale_thresh, max_rot, files @ (tl args))
              | (_,"-v") => read_next ANY (true, log, pyr, max_ints, max_iters, stale_thresh, max_rot, files) (tl args)
              | (_,"--verbose") => read_next ANY (true, log, pyr, max_ints, max_iters, stale_thresh, max_rot, files) (tl args)
              | (_,"-h") => raise Usage
              | (_,"--help") => raise Usage
              | (_,f) => case String.isPrefix "-" f of
                           true => raise Usage
                         | _ => read_next ANY (verbose, log, pyr, max_ints, max_iters, stale_thresh, max_rot, files @ [f]) (tl args)
            end
    end

    val res = read_next ANY (false, NONE, false, NONE, SOME (IntInf.fromInt 1), SOME (IntInf.fromInt 10), SOME 0w0, []) args
    val _ = if #8 res = [] then raise Fail "no input files" else ()
  in
    (* do we want to check log existence here ? *)
    (* do we want to check algorithm vs max_ints presence ? *)
    (SOME res)
  end
  handle Usage => (printUsage cmd_name; NONE)
       | Fail msg => (printErr ("Error: " ^ msg ^ "\n\n"); printUsage cmd_name; NONE)

  fun reader getCmdName getArgs =
    fn () => read ((OS.Path.file o getCmdName) ()) (getArgs ())

end

