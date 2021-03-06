(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

functor PyrStore(N : NUMERIC) : TSP_STORE =
struct

  structure PyrGraph = PyrGraph(N)
  open PyrGraph
  type node = Node.node
  type tour = Tour.tour
  open Thread
  structure Cost = N

  datatype status = DONE of (Cost.num * (unit -> tour)) option
                  | PENDING of ConditionVar.conditionVar

  fun flatCoor (row:word,col:word) =
    if row >= col then Word.toInt (Word.div (row*(row+0w1),0w2) + col)
    else flatCoor (col,row)

  type store = Mutex.mutex vector * status option ref vector

  fun init size = (
    Vector.tabulate (Word.toInt (size*size), fn _ => Mutex.mutex ()),
    Vector.tabulate (Word.toInt (size*size), fn _ => ref NONE)
  )

  fun getToken (mem, (i,j)) = Vector.sub (#1 mem, flatCoor (i,j))

  fun getStatus (mem, (i,j)) = Vector.sub (#2 mem, flatCoor (i,j))

  fun getStats store =
  let
    val (tokens, memo) = store
    val _ = Vector.app Mutex.lock tokens
    val nk = Vector.foldl (fn (e,s) => if isSome (!e) then s+0w1 else s) 0w0 memo
    val nn = Word.fromInt (Vector.length tokens)
  in
    Vector.app Mutex.unlock tokens;
    (nn, nk, 0w0)
  end
end
