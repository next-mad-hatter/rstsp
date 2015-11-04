(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure SBThreadedStore : TSP_THREADED_STORE =
struct

  structure Node = SBNode
  type node = SBNode.node
  structure Tour = SBTour
  type tour = Tour.tour
  type intsset = SBNode.intsset
  open Thread
  open SBUtils

  local
    structure WordPairSetKey = struct
      type ord_key = WordPairSet.set
      val compare = WordPairSet.compare
    end
  in
    structure TypeMap = SplayMapFn(WordPairSetKey)
  end

  datatype status = DONE of (word * tour) option
                  | PENDING of ConditionVar.conditionVar

  (* types store, types store lock, N locks for/and array of N vectors *)
  type store = word TypeMap.map ref * Mutex.mutex * Mutex.mutex Array.array *
               ((Mutex.mutex * status option ref) Vector.vector Array.array)

  (*
  local
    fun synchronized mutex f =
      fn x => (
        (Mutex.lock mutex; f x; Mutex.unlock mutex)
          handle e => (Mutex.unlock mutex; raise e)
      )
  in
    val logErr = synchronized (Mutex.mutex ()) Utils.printErr
  end
  *)

  fun initRow len = Vector.tabulate (len, fn _ => (Mutex.mutex (), ref NONE))

  fun init size = (ref TypeMap.empty, Mutex.mutex (),
                   Array.tabulate (Word.toInt size + 1, fn _ => Mutex.mutex ()),
                   Array.tabulate (Word.toInt size + 1, fn _ => initRow 42))

  fun getType ((mem, token, _, _), node) =
  let
    val tp = (Node.normHash o Node.toHash) node
    val res = case TypeMap.find (!mem, tp) of
                SOME r => r
              | NONE =>
                  let
                    val _ = Mutex.lock token
                  in
                    case TypeMap.find (!mem, tp) of
                      SOME r =>
                      let
                        val _ = Mutex.unlock token
                      in
                        r
                      end
                    | NONE =>
                      let
                        val nt = Word.fromInt (TypeMap.numItems (!mem))
                        (*
                        fun compact (a,b) = if a = b then [a] else [a,b]
                        fun int2str i =
                           "(" ^ ((String.concatWith ",") o
                                  (map (fn x => wordToString (x+0w1))) o
                                  compact) i ^ ")"
                        val typestr = wordToString nt ^ ": " ^
                                        ((String.concatWith " ") o
                                         (map int2str) o
                                         WordPairSet.listItems)
                                           (Node.normNode node)
                        *)
                      in
                        (*
                        logErr ("New type : " ^ typestr ^ "\n");
                        *)
                        mem := TypeMap.insert (!mem, tp, nt);
                        Mutex.unlock token;
                        nt
                      end
                  end
  in
    res
  end

  fun growRow (store, level) =
  let
    val (typemem, _, locks, storemem) = store
    val row = Array.sub (storemem, Word.toInt level)
  in
    case TypeMap.numItems (!typemem) > Vector.length row of
      false => ()
    | _ =>
      let
        val token = Array.sub (locks, Word.toInt level)
        val _ = Mutex.lock token
        val len = Int.max (0, (TypeMap.numItems (!typemem)) - (Vector.length row))
        (*
        val _ = logErr ("Grow by " ^ (Int.toString len) ^ "\n")
        *)
        val tail = initRow len
        val newrow = VectorSlice.concat [VectorSlice.full row, VectorSlice.full tail]
      in
        Array.update (storemem, Word.toInt level, newrow);
        Mutex.unlock token;
        ()
      end
  end

  fun growAllRowsFrom (store, level) =
  let
    val (_, _, _, storemem) = store
    val num = (Array.length storemem) - (Word.toInt level)
    fun iter 0 = ()
      | iter n = (growRow (store, level - 0w1 + Word.fromInt n); iter (n-1))
  in
    iter num
  end

  fun getCell (store, node) =
  let
    val (typemem, token, locks, storemem) = store
    val (level, ints) = node
    val typenum = getType (store, node)
  in
    Vector.sub (Array.sub (storemem, Word.toInt level), Word.toInt typenum)
      handle Subscript => (
        growRow (store, level);
        (*
        growAllRowsFrom (store, level);
        *)
        Vector.sub (Array.sub (storemem, Word.toInt level), Word.toInt typenum)
      )
  end

  val getToken = #1 o getCell

  val getStatus = #2 o getCell

  fun getNumKeys store =
  let
    val (mem, token, _, _) = store
    val _ = Mutex.lock token
    val nk = (Word.fromInt o TypeMap.numItems) (!mem)
  in
    Mutex.unlock token;
    nk
  end

end
