(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

functor TSPSearchFn (G: TSP_GRAPH) :> TSP_SEARCH =
struct

  open G

  local
    structure MemKey =
    struct
      type ord_key = node
      val compare = Node.compare
    end
  in
    structure MemMap: ORD_MAP = SplayMapFn(MemKey)
  end

  (* no recursion here yet *)
  (*
   * TODO: FIXME :)
   *
  fun memoize memo f =
    fn node =>
    let
      val res = MemMap.find (!memo, node)
    in
      case res of
        SOME r => (Utils.printErr "FOUND\n"; r)
      | NONE =>
          let
            val sol = f node
          in
            MemMap.insert (!memo, node, sol);
            sol
          end
    end
   *)

  (*
   * TODO: FIXME :)
   *
  fun dotlog filename f =
  let
    val dotfile = TextIO.openOut "log.dot"
    val log = fn s => TextIO.outputSubstr (dotfile, Substring.full s)
    val _ = log "digraph Log {\n"
    val _ = log "node[shape=box];\n"
  in
    (
      fn node => log o Node.toString,
      fn () => (log "}\n"; TextIO.closeOut dotfile)
    )
  end
   *)

  fun traverse size dist memo node =
  let
    val res = MemMap.find (!memo, node)
  in
    case res of SOME r => r
    | NONE =>
        let val result =
          let
            val collect =
              fn ((new_node, dist_fn, tour_fn), old_sol) =>
              let
                val new_sol = traverse size dist memo new_node
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
            val desc = descend size dist node
          in
            case desc of
              DESC opts => foldl collect NONE opts
            | TERM r => r
          end
        in
          memo := MemMap.insert (!memo, node, result);
          result
        end
  end

  fun search size dist =
  let
    val memo = ref MemMap.empty
    val tr = traverse size dist memo
  in
    fn () =>
    let
      val res = tr root
    in
      case res of
        NONE => NONE
      | SOME (_, t) => SOME t
    end
  end

end
