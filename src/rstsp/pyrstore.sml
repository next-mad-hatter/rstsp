(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure PyrStore : TSP_STORE =
struct

  open PyrGraph
  type node = Node.node
  type tour = Tour.tour
  open Thread

  datatype status = DONE of (word * tour) option
                  | PENDING of ConditionVar.conditionVar

  (*
  type store = (Mutex.mutex * status option ref) Array2.array
  fun init size = Array2.tabulate Array2.RowMajor
                    (Word.toInt size, Word.toInt size,
                      fn (_,_) => (Mutex.mutex (), ref NONE))

  fun getToken (mem, (i,j)) = #1 (Array2.sub (mem, Word.toInt i, Word.toInt j))

  fun getStatus (mem, (i,j)) = #2 (Array2.sub (mem, Word.toInt i, Word.toInt j))
  *)

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
