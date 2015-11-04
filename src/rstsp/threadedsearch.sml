(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

functor ThreadedSearchFn (X: sig structure Graph: TSP_GRAPH; structure Store: TSP_THREADED_STORE where type tour = Graph.tour where type node = Graph.node end) : TSP_SEARCH =
struct

  open X
  open Graph
  open Thread.Thread
  open Thread.Mutex
  open Thread.ConditionVar
  open Store

  fun synchronized mutex f =
    fn x => (
      (lock mutex; f x; unlock mutex)
        handle e => (unlock mutex; raise e)
    )

  val logErr = synchronized (mutex ()) Utils.printErr

  (*
   * (log vertex, log value, close file) functions tuple
   *)
  fun dotlogs filename =
  let
    val token = mutex ()
    val dotfile = TextIO.openOut filename
    fun writestr s = TextIO.outputSubstr (dotfile, Substring.full s)
    val log = synchronized token writestr
    val _ = log "digraph Log {\n"
    val _ = log "node[shape=box];\n"
  in
    (
      fn (node, node') => log
        ("\"" ^ Node.toString node ^ "\" -> \"" ^ Node.toString node' ^ "\";\n")
        ,
      fn (node, tour) => log
        ("\"" ^ Node.toString node ^ "\" [xlabel = \"" ^ Tour.toString tour ^ "\"]; \n"),
      fn () => (synchronized token (fn () => (writestr "}\n"; TextIO.closeOut dotfile))) ()
    )
  end

  (*
  datatype status = DONE of (word * tour) option
                  | PENDING of conditionVar
  *)

  fun getCV (PENDING c) = c
    | getCV _ = raise Fail "No CV"

  fun traverse size dist (log_vertex, log_value) options =
  let

    val store = Store.init size

    fun compute node (cell, token) =
    let
      val result =
      let
        val collect =
          fn ((new_node, dist_fn, tour_fn), old_sol) =>
          let
            val new_sol = trav new_node
            val _ = (fork (fn () => log_vertex (node, new_node), []); ())
          in
            case new_sol of
              NONE => old_sol
            | SOME (d, t) =>
              case old_sol of
                   NONE => SOME (dist_fn d, tour_fn t)
                 | SOME (d', t') =>
                     let
                       val d'' = dist_fn d
                     in
                       case d' <= d'' of
                         true => SOME (d', t')
                       | _ => SOME (d'', tour_fn t)
                     end
          end
        val desc = descend size dist options node
      in
        case desc of
          DESC opts => foldl collect NONE opts
        | TERM r => r
      end
      fun unpack (SOME (PENDING c)) = c
        | unpack _ = raise Fail "Ho"
      val cv = unpack (!cell)
    in
      lock token;
      cell := SOME (DONE result);
      unlock token;
      broadcast cv;
      if isSome result then
        (
          (* logErr ("Done " ^ (Node.toString node) ^ "\n"); *)
          fork (fn () => log_value (node, (#2 o valOf) result), []);
          ()
        )
        else ()
    end
    and trav node =
      let
        val token = Store.getToken (store, node)
        val _ = lock token
        val cell = Store.getStatus (store, node)
        val _ = case !cell of
          NONE =>
          (
            cell := SOME (PENDING (conditionVar ()));
            (* logErr ("Fork " ^ (Node.toString node) ^ "\n"); *)
            fork (fn () => compute node (cell, token), []);
            ()
          )
        | _ => ()
        fun unpack (SOME (DONE r)) = r
          | unpack _ = raise Fail "Ooops"
      in
        case !cell of
          SOME (DONE r) => (unlock token; r)
        | SOME (PENDING cv) =>
          let
            val _ = wait (cv, token)
          in
            unlock token;
            unpack (!cell)
          end
        | _ => raise Fail "Shutup compiler"
      end
  in
    trav
  end

  fun search size dist dotfilename options =
  let
    val (log_vertex, log_value, close_log) =
      case dotfilename of
        NONE => (fn _ => (), fn _ => (), fn _ => ())
      | SOME filename => dotlogs filename
    val trav = traverse size dist (log_vertex, log_value) options
  in
    fn () =>
    (
      let
        val res = trav root
        val _ = close_log ()
      in
        case res of
          NONE => NONE
        | SOME (_, t) => SOME t
      end
    ) handle e => (close_log (); raise e)
  end

end
