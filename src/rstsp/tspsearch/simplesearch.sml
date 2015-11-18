(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Simple recursive traversal, equivalent to depth first search.
 *
 * A hash table is used for memoization.
 *)
functor SimpleSearchFn(G: TSP_GRAPH) : TSP_SEARCH =
struct

  structure U = Utils
  structure T = G.Tour
  structure N = G.Node
  open TSPTypes
  datatype descent = datatype G.descent

  structure Len = G.Len

  type tour = G.tour

  type optional_params = G.optional_params

  val tourToVector = T.toVector

  val tourToString = T.toString

  (**
   * For dot logging, returns (log vertex, log value, close file) functions.
   *)
  fun dotlogs filename =
  let
    val dotfile = TextIO.openOut filename
    val log = fn s => TextIO.outputSubstr (dotfile, Substring.full s)
    val _ = log "digraph Log {\n"
    val _ = log "node[shape=box];\n"
  in
    (
      fn (node, node') => log ("\"" ^ N.toString node ^ "\" -> \"" ^ N.toString node' ^ "\";\n"),
      fn (node, tour) => log ("\"" ^ N.toString node ^ "\" [xlabel = \"" ^ T.toString tour ^ "\"]; \n"),
      fn () => (log "}\n"; TextIO.closeOut dotfile)
    )
  end

  fun traverse size dist (log_vertex, log_value) options =
  let

    fun trav memo node =
      let
        val res = HashTable.find memo (N.toKey node)
      in
        case res of SOME r => r
        | NONE =>
            let val result =
              let
                val collect =
                  fn ((new_node, dist_fn, tour_fn), old_sol) =>
                  let
                    val new_sol = trav memo new_node
                    val _ = case log_vertex of
                              SOME f => f (node, new_node)
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
                               case Len.compare (d', d'') of
                                 GREATER => SOME (d'', tour_fn t)
                               | _ => SOME (d', t')
                             end
                  end
                val desc = G.descendants size dist options node
              in
                case desc of
                  DESC opts => foldl collect NONE opts
                | TERM r => r
              end
              val _ = case (result, log_value) of
                        (SOME (_,r), SOME f) => f (node, r ())
                      | (_,_) => ()
            in
              HashTable.insert memo (N.toKey node, result);
              result
            end
      end
  in
    trav
  end

  exception HTMiss

  fun search size dist dotfilename wants_stats options =
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
        val hasher = N.toHash size
        val memo: (N.key, (Len.num * (unit -> T.tour)) option) HashTable.hash_table =
          HashTable.mkTable
          (hasher, fn (a,b) => (N.compare (a,b) = EQUAL))
          (Word.toInt (G.HTSize (size,options)), HTMiss)
        val res = trav memo G.root
        val _ = close_log ()
        val nk =
          case wants_stats of
            false => NONE
          | _ => SOME (
            Word.fromInt (HashTable.numItems memo)
            ,
            (Word.fromInt o WordPairSetSet.numItems)
            (HashTable.foldi
              (fn (k, _, s) => WordPairSetSet.add (s, N.normKey k))
              WordPairSetSet.empty memo),
            (Word.fromInt o List.length o
             (ListMergeSort.uniqueSort Word.compare) o
             (map hasher) o
             (map #1) o
             HashTable.listItemsi) memo
          )
      in
        (res, nk)
      end
    ) handle e => (close_log; raise e)
  end

end
