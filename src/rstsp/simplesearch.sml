(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

functor SimpleSearchFn ( G: TSP_GRAPH ) : TSP_SEARCH =
struct

  open G
  open Utils

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
    val dotfile = TextIO.openOut filename
    val log = fn s => TextIO.outputSubstr (dotfile, Substring.full s)
    val _ = log "digraph Log {\n"
    val _ = log "node[shape=box];\n"
  in
    (
      fn (node, node') => log
        ("\"" ^ Node.toString node ^ "\" -> \"" ^ Node.toString node' ^ "\";\n")
        ,
      fn (node, tour) => log
        ("\"" ^ Node.toString node ^ "\" [xlabel = \"" ^ Tour.toString tour ^ "\"]; \n"),
      fn () => (log "}\n"; TextIO.closeOut dotfile)
    )
  end

  fun traverse size dist (log_vertex, log_value) options =
  let

    fun trav memo node =
      let
        val res = MemMap.find (!memo, Node.toHash node)
      in
        case res of SOME r => r
        | NONE =>
            let val result =
              let
                val collect =
                  fn ((new_node, dist_fn, tour_fn), old_sol) =>
                  let
                    val new_sol = trav memo new_node
                    val _ = log_vertex (node, new_node)
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
            in
              if isSome result then log_value (node, (#2 o valOf) result) else ();
              memo := MemMap.insert (!memo, Node.toHash node, result);
              result
            end
      end
  in
    trav
  end

  fun search size dist dotfilename wants_count options =
  let
    val (log_vertex, log_value, close_log) =
      case dotfilename of
        SOME filename => dotlogs filename
      | NONE => (fn _ => (), fn _ => (), fn _ => ())
    val trav = traverse size dist (log_vertex, log_value) options
  in
    fn () =>
    (
      let
        val memo = ref MemMap.empty
        val res = trav memo root
        val _ = close_log ()
        val nk =
          case wants_count of
            false => NONE
          | _ => SOME (
            (Word.fromInt o WordPairSetSet.numItems)
            (MemMap.foldli
              (fn (k, _, s) => WordPairSetSet.add (s, Node.normHash k))
              WordPairSetSet.empty (!memo))
          )
      in
        case res of
          NONE => (NONE, nk)
        | SOME (_, t) => (SOME t, nk)
      end
    ) handle e => (close_log; raise e)
  end

end
