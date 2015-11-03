(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

functor CMLSearchFn (G: TSP_GRAPH) : TSP_SEARCH =
struct

  open CML
  open SyncVar
  open G

  local
    structure MemKey =
    struct
      type ord_key = Node.hash
      val compare = Node.compare
    end
  in
    structure MemMap: ORD_MAP = SplayMapFn(MemKey)
  end

  (*
   * (log vertex, log value, close file) functions tuple
   *)
  fun dotlogs filename =
  let
    val store = mVarInit ()
    val dotfile = TextIO.openOut filename
    fun writestr s = TextIO.outputSubstr (dotfile, Substring.full s)
    fun log s =
    let
      val _ = mTake store
    in
      (writestr s; mPut (store, ()))
        handle e => (mPut (store, ()); raise e)
    end
    val _ = log "digraph Log {\n"
    val _ = log "node[shape=box];\n"
  in
    (
      fn (node, node') => log
        ("\"" ^ Node.toString node ^ "\" -> \"" ^ Node.toString node' ^ "\";\n")
        ,
      fn (node, tour) => log
        ("\"" ^ Node.toString node ^ "\" [xlabel = \"" ^ Tour.toString tour ^ "\"]; \n"),
      fn () => (
        (mTake store; writestr "}\n"; TextIO.closeOut dotfile; mPut (store, ()))
          handle e => (mPut (store, ()); raise e))
    )
  end

  datatype status = DONE of (word * tour) option
                  | PENDING of (((word * tour) option) Multicast.mchan)

  fun getChannel (PENDING c) = c
    | getChannel _ = raise Fail "No Channel"

  fun traverse size dist (log_vertex, log_value) options =
  let

    val storage = mVarInit MemMap.empty

    fun compute node =
    let
      val result =
      let
        val collect =
          fn ((new_node, dist_fn, tour_fn), old_sol) =>
          let
            val new_sol = trav new_node
            val _ = spawn (fn () => log_vertex (node, new_node))
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
      val mem = mTake storage
      val chan = (getChannel o valOf o MemMap.find) (mem, Node.toHash node)
    in
      Multicast.multicast (chan, result);
      mPut (storage, MemMap.insert (mem, Node.toHash node, DONE result));
      if isSome result then log_value (node, (#2 o valOf) result) else ()
    end
    and trav node =
      let
        val mem = mTake storage
        val res = MemMap.find (mem, Node.toHash node)
      in
        case res of
          SOME (DONE r) => (mPut (storage, mem); r)
        | _ =>
            let
              val chan = case res of
                           SOME (PENDING c) => c
                         | _ => Multicast.mChannel ()
              val port = Multicast.port chan
            in
              mPut (storage, MemMap.insert (mem, Node.toHash node, PENDING chan));
              if isSome res then () else (spawn (fn () => compute node); ());
              Multicast.recv port
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
