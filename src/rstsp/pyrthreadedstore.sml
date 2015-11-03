(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure PyrThreadedStore : TSP_THREADED_STORE =
struct

  open PyrGraph
  type node = Node.node
  type tour = Tour.tour
  open Thread

  datatype status = DONE of (word * tour) option
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

end
