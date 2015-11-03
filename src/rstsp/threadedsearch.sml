(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

functor ThreadedSearchFn (G: TSP_GRAPH) : TSP_SEARCH =
struct

  open G
  open Thread
  open Thread
  open Mutex
  open ConditionVar

  local
    structure MemKey =
    struct
      type ord_key = Node.hash
      val compare = Node.compare
    end
  in
    structure MemMap: ORD_MAP = SplayMapFn(MemKey)
  end

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

  datatype status = DONE of (word * tour) option
                  | PENDING of conditionVar

  fun getCV (PENDING c) = c
    | getCV _ = raise Fail "No CV"

  fun traverse size dist (log_vertex, log_value) options =
  let

    val memo = ref MemMap.empty
    val mem_token = mutex ()
    (*
    val find = synchronized mem_token (fn x => MemMap.find (!memo, x))
    val insert = synchronized mem_token (fn (x,v) => MemMap.insert (!memo, x, v))
    *)
    (*
     * TODO: memoize per level for SB graphs -> faster access?
     *
    val memo = Vector.tabulate size (fn _ => mVarInit MemMap.empty)
    *)

    fun compute node =
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
      val _ = lock mem_token
      val cv = (getCV o valOf o MemMap.find) (!memo, Node.toHash node)
    in
      memo := MemMap.insert (!memo, Node.toHash node, DONE result);
      unlock mem_token;
      broadcast cv;
      if isSome result then
          (
            logErr ("Done " ^ (Node.toString node) ^ "\n");
          fork (fn () => log_value (node, (#2 o valOf) result), []); ())
        else ()
    end
    and trav node =
      let
        val _ = lock mem_token
        val res = MemMap.find (!memo, Node.toHash node)
      in
        case res of
          SOME (DONE r) =>
            (
              unlock mem_token;
              r
            )
        | _ =>
            let
              val cv = case res of
                         SOME (PENDING c) => c
                       | NONE =>
                           let
                             val nc = conditionVar ()
                           in
                             logErr ("Forking " ^ (Node.toString node) ^ "\n");
                             fork (fn () => compute node, []);
                             memo := MemMap.insert (!memo, Node.toHash node, PENDING nc);
                             nc
                           end
                        | _ => raise Fail "shut up compiler"
              val _ = wait (cv, mem_token)
              val r = MemMap.find (!memo, Node.toHash node)
              fun unpack (SOME (DONE r)) = r
                | unpack _ = raise Fail "Ooops"
            in
              unlock mem_token;
              unpack r
            end
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
