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
   *    files: string list
   *   option (when wrong args/empty files list).
   *)
  val reader: (unit -> string) -> (unit -> string list) ->
    unit -> (bool * string option * bool * word option * IntInf.int option * string list) option

end

structure Options : OPTIONS =
struct

  open Utils

  exception Usage

  datatype expect = ANY | ALGO | LOG | MAX_INTS | MAX_ITERS

  fun expect "-t" = ALGO
    | expect "--type" = ALGO
    | expect "-l" = LOG
    | expect "--log" = LOG
    | expect "-m" = MAX_INTS
    | expect "--max" = MAX_INTS
    | expect "-i" = MAX_ITERS
    | expect "--iter" = MAX_ITERS
    | expect _ = ANY

  fun printUsage cmd_name = (
    print "Usage:\n";
    print ("  " ^ cmd_name ^ " -h|--help\n");
    print ("  " ^ cmd_name ^ " [options] file(s)\n");
    print "where options are any of:\n";
    print "    -h|--help      :  print this message and quit\n";
    print "    -t|--type p|b  :  pyramidal|balanced search\n";
    print "                      (default: balanced)\n";
    print "    -m|--max width :  maximum node width for balanced search\n";
    print "                      (zero for unlimited)";
    print "                      (default: none)\n";
    print "    -i|--iter num  :  maximum number of iterations in local search\n";
    print "                      (zero for unlimited)";
    print "                      (default: 1, i.e. no local search)\n";
    print "    -l|--log file  :  if specified, traversal trace (in dot format)\n";
    print "                      will be written to the file\n";
    print "    -v|--verbose   :  print additional info (such as store statistics)\n";
    print "\n";
    ()
    )

  fun read cmd_name args =
  let

    fun read_next expects opts args =
    let
      val (verbose, log, pyr, max_ints, max_iters, files) = opts
    in
      case expects of
        ALGO =>
        let
          val new_opts =
            case (String.isPrefix (hd args) "pyramidal",
                  String.isPrefix (hd args) "balanced") of
              (true,_) => (verbose, log, true, max_ints, max_iters, files)
            | (_,true) => (verbose, log, false, max_ints, max_iters, files)
            | _ => raise Fail ("unknown algorithm: " ^ hd args)
        in
          read_next ANY new_opts (tl args)
        end
      | LOG =>
        let
          val new_opts =
            case log of
              NONE => (verbose, SOME (hd args), pyr, max_ints, max_iters, files)
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
              SOME 0w0 => (verbose, log, pyr, NONE, max_iters, files)
            | SOME m => (verbose, log, pyr, SOME m, max_iters, files)
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
                    true => (verbose, log, pyr, max_ints, NONE, files)
                  | false => (verbose, log, pyr, max_ints, SOME m, files)
                )
            | NONE => raise Fail ("invalid maximum intervals number")
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
              val (verbose, log, pyr, max_ints, max_iters, files) = opts
            in
              case (expect (hd args), hd args) of
                (ALGO,_) => read_next ALGO opts (tl args)
              | (LOG,_) => read_next LOG opts (tl args)
              | (MAX_INTS,_) => read_next MAX_INTS opts (tl args)
              | (MAX_ITERS,_) => read_next MAX_ITERS opts (tl args)
              | (_,"--") => (verbose, log, pyr, max_ints, max_iters, files @ (tl args))
              | (_,"-v") => read_next ANY (true, log, pyr, max_ints, max_iters, files) (tl args)
              | (_,"--verbose") => read_next ANY (true, log, pyr, max_ints, max_iters, files) (tl args)
              | (_,"-h") => raise Usage
              | (_,"--help") => raise Usage
              | (_,f) => case String.isPrefix "-" f of
                           true => raise Usage
                         | _ => read_next ANY (verbose, log, pyr, max_ints, max_iters, files @ [f]) (tl args)
            end
    end

    val res = read_next ANY (false, NONE, false, NONE, SOME (IntInf.fromInt 1), []) args
    val _ = if #6 res = [] then raise Fail "no input files" else ()
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

