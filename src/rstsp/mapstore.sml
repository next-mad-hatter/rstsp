(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

functor MapStore(G: TSP_GRAPH) : TSP_STORE =
struct

  open G
  type node = G.Node.node
  type tour = G.Tour.tour
  open Thread

  local
    structure MemKey =
    struct
      type ord_key = Node.hash
      val compare = Node.compare
    end
  in
    structure MemMap: ORD_MAP = SplayMapFn(MemKey)
    structure KeySet: ORD_SET = SplaySetFn(MemKey)
  end

  datatype status = DONE of (word * (unit -> tour)) option
                  | PENDING of ConditionVar.conditionVar

  type store = (Mutex.mutex * status option ref) MemMap.map ref * Mutex.mutex
  fun init _ = (ref MemMap.empty, Mutex.mutex ())

  fun find' (mem, mut, node) =
  let
    val _ = Mutex.lock mut
    val res = case MemMap.find (!mem, Node.toHash node) of
                SOME r => r
              | NONE =>
                  let
                    val r = (Mutex.mutex (), ref NONE)
                  in
                    mem := MemMap.insert (!mem, Node.toHash node, r);
                    r
                  end
  in
    Mutex.unlock mut;
    res
  end

  fun getToken ((mem, mut), node) =
  let
    val (m, _) = find' (mem, mut, node)
  in
    m
  end

  fun getStatus ((mem, mut), node) =
  let
    val (_, v) = find' (mem, mut, node)
  in
    v
  end

  fun getStats store =
  let
    val (mem, mut) = store
    val _ = Mutex.lock mut
    val nk = (Word.fromInt o KeySet.numItems)
             (MemMap.foldli (fn (k, _, s) => KeySet.add (s, k)) KeySet.empty (!mem))
    val nn = (Word.fromInt o MemMap.numItems) (!mem)
  in
    Mutex.unlock mut;
    (nn, nk)
  end

end
