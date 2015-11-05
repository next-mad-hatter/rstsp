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
   *    files: string list
   *   option (when wrong args/empty files list).
   *)
  val reader: (unit -> string) -> (unit -> string list) ->
    unit -> (bool * string option * bool * word option * string list) option

end

structure Options : OPTIONS =
struct

  open Utils

  exception Usage

  datatype expect = ANY | ALGO | LOG | MAX_INTS

  fun expect "-t" = ALGO
    | expect "--type" = ALGO
    | expect "-l" = LOG
    | expect "--log" = LOG
    | expect "-m" = MAX_INTS
    | expect "--max" = MAX_INTS
    | expect _ = ANY

  fun printUsage cmd_name = (
    print "Usage:\n";
    print ("  " ^ cmd_name ^ " -h|--help\n");
    print ("  " ^ cmd_name ^ " [options] file(s)\n");
    print "where options are any of:\n";
    print "    -h|--help file :  print this message and quit\n";
    print "    -l|--log file  :  dot log\n";
    print "    -v|--verbose   :  print store statistics\n";
    print "    -t|--type p|b  :  pyramidal|balanced search\n";
    print "    -m|--max width :  maximum node width for balanced search\n";
    print "\n";
    ()
    )

  fun read cmd_name args =
  let

    fun read_next expects opts args =
    let
      val (verbose, log, pyr, max_ints, files) = opts
    in
      case expects of
        ALGO =>
        let
          val new_opts =
            case hd args of
              "p" => (verbose, log, true, max_ints, files)
            | "b" => (verbose, log, false, max_ints, files)
            | _ => raise Fail ("unknown algorithm: " ^ hd args)
        in
          read_next ANY new_opts (tl args)
        end
      | LOG =>
        let
          val new_opts =
            case log of
              NONE => (verbose, SOME (hd args), pyr, max_ints, files)
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
              SOME 0w0 => (verbose, log, pyr, NONE, files)
            | SOME m => (verbose, log, pyr, SOME m, files)
            | _ => raise Fail ("invalid maximum intervals number")
        in
          read_next ANY new_opts (tl args)
        end
      | ANY =>
          case args of
            [] => opts
          | _ =>
            let
              val (verbose, log, pyr, max_ints, files) = opts
            in
              case (expect (hd args), hd args) of
                (ALGO,_) => read_next ALGO opts (tl args)
              | (LOG,_) => read_next LOG opts (tl args)
              | (MAX_INTS,_) => read_next MAX_INTS opts (tl args)
              | (_,"--") => (verbose, log, pyr, max_ints, files @ (tl args))
              | (_,"-v") => read_next ANY (true, log, pyr, max_ints, files) (tl args)
              | (_,"--verbose") => read_next ANY (true, log, pyr, max_ints, files) (tl args)
              | (_,"-h") => raise Usage
              | (_,"--help") => raise Usage
              | (_,f) => case String.isPrefix "-" f of
                           true => raise Usage
                         | _ => read_next ANY (verbose, log, pyr, max_ints, files @ [f]) (tl args)
            end
    end

    val res = read_next ANY (false, NONE, false, NONE, []) args
    val _ = if #5 res = [] then raise Fail "no input files" else ()
  in
    (* do we want to check log existence here ? *)
    (* do we want to check algorithm vs max_ints presence ? *)
    (SOME res)
  end
  handle Usage => (printUsage cmd_name; NONE)
       | Fail msg => (printErr ("Error: " ^ msg ^ "\n\n"); printUsage cmd_name; NONE)

  fun reader getCmdName getArgs =
    fn () => read (getCmdName ()) (getArgs ())

end

