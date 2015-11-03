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

  local
    structure MemKey =
    struct
      type ord_key = Node.hash
      val compare = Node.compare
    end
  in
    structure MemMap: ORD_MAP = SplayMapFn(MemKey)
  end

  type store = (word * tour) option MemMap.map ref
  fun init _ = ref MemMap.empty

  fun getResult (mem, node) =
    MemMap.find (!mem, Node.toHash node)

  fun setResult (mem, node, res) =
    mem := MemMap.insert (!mem, Node.toHash node, res);

end
