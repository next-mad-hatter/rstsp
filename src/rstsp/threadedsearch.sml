(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

functor ThreadedSearchFn (X: sig structure Graph: TSP_GRAPH; structure Store: TSP_STORE where type tour = Graph.tour where type node = Graph.node end) : TSP_SEARCH =
struct

  open X
  open Graph
  open Thread.Thread
  open Thread.Mutex
  open Thread.ConditionVar
  open Store

  val toVector = Tour.toVector
  val toString = Tour.toString

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

    fun compute store node (cell, token) =
    let
      val result =
      let
        val collect =
          fn ((new_node, dist_fn, tour_fn), old_sol) =>
          let
            val new_sol = trav store new_node
            val _ = case log_vertex of
                      SOME f => (fork (fn () => f (node, new_node), []); ())
                    | NONE => ()
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
      if isSome result andalso isSome log_value then
        (
          (* logErr ("Done " ^ (Node.toString node) ^ "\n"); *)
          fork (fn () => (valOf log_value) (node, ((#2 o valOf) result) ()), []);
          ()
        )
        else ()
    end
    and trav store node =
      let
        val token = Store.getToken (store, node)
        val _ = lock token
        val cell = Store.getStatus (store, node)
        val _ = case !cell of
          NONE =>
          (
            cell := SOME (PENDING (conditionVar ()));
            (* logErr ("Fork " ^ (Node.toString node) ^ "\n"); *)
            fork (fn () => compute store node (cell, token), []);
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

  fun search size dist dotfilename wants_count options =
  let
    val (log_vertex, log_value, close_log) =
      case dotfilename of
        NONE => (NONE, NONE, fn () => ())
      | SOME filename =>
          let
            val (f,g,h) = dotlogs filename
          in
            (SOME f, SOME g, h)
          end
    val trav = traverse size dist (log_vertex, log_value) options
  in
    fn () =>
    (
      let
        val store = Store.init size
        val res = trav store root
        val _ = close_log ()
        val nk =
          case wants_count of
            false => NONE
          | _ => SOME (Store.getStats store)
      in
        (res, nk)
      end
    ) handle e => (close_log (); raise e)
  end

end
