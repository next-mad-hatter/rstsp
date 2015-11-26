(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature OPTIONS =
sig

  (**
   * Given a command name reader and arguments reader, returns a
   *
   *  (  bool               : verbose
   *   * string option      : dot file name
   *   * bool               : pyramidal
   *   * word option        : interval size limit
   *   * IntInf.int option  : iterations limit
   *   * IntInf.int option  : stale iterations limit
   *   * word option        : if SOME: starting rotations number for adaptive search, in NONE: no adaptive search
   *   * word option        : rotations limit
   *   * IntInf.int option  : flipflops limit
   *   * string list        : filenames
   *  ) option              : in case of bad args
   *
   *  reader.
   *)
  val reader : (unit -> string) -> (unit -> string list) ->
               unit -> (bool * string option *
                        bool * word option *
                        IntInf.int option * IntInf.int option *
                        word option * word option * IntInf.int option *
                        string list) option

end

(**
 * Very simple options parser.
 *
 * This will become unwieldy quickly as number of options increases --
 * for a possible solution, see http://mlton.org/FunctionalRecordUpdate .
 *)
structure Options : OPTIONS =
struct

  structure U = Utils

  exception Usage

  datatype expect = ANY | ALGO | LOG | MAX_NODE_SIZE | MAX_ITERS | STALE_THRESH | MIN_ROT | MAX_ROT | MAX_FLIPS

  fun expect "-t" = ALGO
    | expect "--type" = ALGO
    | expect "-l" = LOG
    | expect "--log" = LOG
    | expect "-m" = MAX_NODE_SIZE
    | expect "--max" = MAX_NODE_SIZE
    | expect "-i" = MAX_ITERS
    | expect "--iter" = MAX_ITERS
    | expect "-j" = STALE_THRESH
    | expect "--stale" = STALE_THRESH
    | expect "-r" = MAX_ROT
    | expect "--rot" = MAX_ROT
    | expect "-a" = MIN_ROT
    | expect "--adaptve" = MIN_ROT
    | expect "-f" = MAX_FLIPS
    | expect "--flips" = MAX_FLIPS
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
    print "    -m|--max width :  maximum number of intervals in a node for balanced search\n";
    print "                      (zero for unlimited, default: 4)\n";
    print "\n";
    print "    -i|--iter num  :  perform local search with given maximum number of iterations\n";
    print "                      (zero for unlimited, default: 1, i.e. no local search)\n";
    print "\n";
    print "    -j|--stale num :  maximum number of stale iterations in local search\n";
    print "                      (zero for unlimited, default: 1)\n";
    print "\n";
    print "  -r|--rot all|num :  maximum number of permutations in local search\n";
    print "                      (\"all\" for maximum possible, default: 0)\n";
    print "\n";
    print "    -a|--adapt num :  perform adaptive search starting at given rotations number\n";
    print "\n";
    print "    -f|--flips num :  combine adaptive balanced search with iterative pyramidal search,\n";
    print "                      limiting flipflops by given number, zero for unlimited\n";
    print "                      (number of pyramidal iterations will be limited by common limit\n";
    print "                       as well as balanced permutations limit)\n";
    print "\n";
    print "    -l|--log file  :  if specified, traversal trace (in dot format)\n";
    print "                      will be written to the file -- only valid for single traversals\n";
    print "\n";
    print "    -v|--verbose   :  print additional info (such as store statistics)\n";
    print "\n";
    print "    --             :  options terminator\n";
    print "\n";
    print "When a file named \"-\" is encountered, standard input will be read instead.\n";
    print "\n";
    ()
    )

  fun read cmd_name args =
  let

    fun read_next expects opts args =
    let
      val (verbose, log, pyr, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, files) = opts
    in
      case expects of
        ALGO =>
        let
          val new_opts =
            case (String.isPrefix (hd args) "pyramidal",
                  String.isPrefix (hd args) "balanced") of
              (true,_) => (verbose, log, true, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, files)
            | (_,true) => (verbose, log, false, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, files)
            | _ => raise Fail ("unknown algorithm: " ^ hd args)
        in
          read_next ANY new_opts (tl args)
        end
      | LOG =>
        let
          val new_opts =
            case log of
              NONE => (verbose, SOME (hd args), pyr, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, files)
            | SOME l =>
                case l = hd args of
                  true => opts
                | _ => raise Fail ("multiple log files requested")
        in
          read_next ANY new_opts (tl args)
        end
      | MAX_NODE_SIZE =>
        let
          val new_opts =
            case U.wordFromString (hd args) of
              SOME 0w0 => (verbose, log, pyr, NONE, max_iters, stale_thresh, min_rot, max_rot, max_flips, files)
            | SOME m => (verbose, log, pyr, SOME m, max_iters, stale_thresh, min_rot, max_rot, max_flips, files)
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
                    true => (verbose, log, pyr, max_node_size, NONE, stale_thresh, min_rot, max_rot, max_flips, files)
                  | false => (verbose, log, pyr, max_node_size, SOME m, stale_thresh, min_rot, max_rot, max_flips, files)
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
                    true => (verbose, log, pyr, max_node_size, max_iters, NONE, min_rot, max_rot, max_flips, files)
                  | false => (verbose, log, pyr, max_node_size, max_iters, SOME m, min_rot, max_rot, max_flips, files)
                )
            | NONE => raise Fail ("invalid stale intervals number")
        in
          read_next ANY new_opts (tl args)
        end
      | MIN_ROT =>
        let
          val new_opts =
            case (U.wordFromString o hd) args of
              SOME m => (verbose, log, pyr, max_node_size, max_iters, stale_thresh, SOME m, max_rot, max_flips, files)
            | NONE => raise Fail ("invalid adaptive rotations number")
        in
          read_next ANY new_opts (tl args)
        end
      | MAX_ROT =>
        let
          val new_opts =
            case hd args of
              "all" => (verbose, log, pyr, max_node_size, max_iters, stale_thresh, min_rot, NONE, max_flips, files)
            | str => case U.wordFromString str of
                       SOME m => (verbose, log, pyr, max_node_size, max_iters, stale_thresh, min_rot, SOME m, max_flips, files)
                     | NONE => raise Fail ("invalid maximum rotations number")
        in
          read_next ANY new_opts (tl args)
        end
      | MAX_FLIPS =>
        let
          val new_opts =
            case IntInf.fromString (hd args) of
              SOME m =>
                (
                  case m = IntInf.fromInt 0 of
                    true => (verbose, log, pyr, max_node_size, max_iters, stale_thresh, min_rot, max_rot, NONE, files)
                  | false => (verbose, log, pyr, max_node_size, max_iters, stale_thresh, min_rot, max_rot, SOME m, files)
                )
            | NONE => raise Fail ("invalid flips limit")
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
              val (verbose, log, pyr, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, files) = opts
            in
              case (expect (hd args), hd args) of
                (ALGO,_) => read_next ALGO opts (tl args)
              | (LOG,_) => read_next LOG opts (tl args)
              | (MAX_NODE_SIZE,_) => read_next MAX_NODE_SIZE opts (tl args)
              | (MAX_ITERS,_) => read_next MAX_ITERS opts (tl args)
              | (STALE_THRESH,_) => read_next STALE_THRESH opts (tl args)
              | (MIN_ROT,_) => read_next MIN_ROT opts (tl args)
              | (MAX_ROT,_) => read_next MAX_ROT opts (tl args)
              | (MAX_FLIPS,_) => read_next MAX_FLIPS opts (tl args)
              | (_,"--") => (verbose, log, pyr, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, files @ (tl args))
              | (_,"-v") => read_next ANY (true, log, pyr, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, files) (tl args)
              | (_,"--verbose") => read_next ANY (true, log, pyr, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, files) (tl args)
              | (_,"-h") => raise Usage
              | (_,"--help") => raise Usage
              | (_,f) => case String.isPrefix "-" f andalso size f > 1 of
                           true => raise Usage
                         | _ => read_next ANY (verbose, log, pyr, max_node_size, max_iters, stale_thresh, min_rot, max_rot, max_flips, files @ [f]) (tl args)
            end
    end

    val res = read_next ANY (false, NONE, false, SOME 0w4, SOME (IntInf.fromInt 1), SOME (IntInf.fromInt 1), NONE, SOME 0w0, SOME (IntInf.fromInt 0), []) args
    val _ = if #10 res = [] then raise Fail "no input files" else ()
  in
    (SOME res)
  end
  handle Usage => (printUsage cmd_name; NONE)
       | Empty => (printUsage cmd_name; NONE)
       | Fail msg => (U.printErr ("Error: " ^ msg ^ "\n\n"); printUsage cmd_name; NONE)

  fun reader getCmdName getArgs =
    fn () => read ((OS.Path.file o getCmdName) ()) (getArgs ())

end
