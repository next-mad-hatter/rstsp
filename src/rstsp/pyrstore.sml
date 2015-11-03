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

  fun flatCoor (row:word,col:word) =
    if row >= col then Word.toInt (Word.div (row*(row+0w1),0w2) + col)
    else flatCoor (col,row)

  type store = (word * tour) option option array

  fun init size = Array.array (Word.toInt (size*size), NONE)

  fun getResult (mem, (i,j)) = Array.sub (mem, flatCoor (i,j))

  fun setResult (mem, (i,j), res) = Array.update (mem, flatCoor (i,j), SOME res)

end
