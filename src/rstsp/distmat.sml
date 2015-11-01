(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure DistMat: DIST_MAT = struct

  open Utils

  type t = word vector

  (*
  * For now, only symmetric matrices are supported.
  * This maps them onto flat-indexed vectors.
  *)
  fun flatCoor (row:word,col:word) =
    if row >= col then Word.toInt (Word.div (row*(row+0w1),0w2) + col)
    else flatCoor (col,row)

  fun getDist v (row,col) = Vector.sub (v, flatCoor (row,col))

  local
    fun insert v (row,col) d =
      (if row <= col then Vector.update (v, flatCoor (row,col), d)
       else if getDist v (row,col) = d then v
       else raise Fail "Only symmetric matrices are supported."
       )
         handle Subscript => raise Fail "Too many rows."

    fun addrow v row ds = let
      fun addr v _ _ [] = v
        | addr v row col (d::ds) = addr (insert v (row,col) d) row (col+0w1) ds
    in
      addr v row 0w0 ds
    end

    fun readr data size row input = let
      val line = TextIO.inputLine input
    in
      if line = NONE then data
      else if stripWS (valOf line) = "" then readr data size row input
      else let
        val ds = ((map (fn w => if isSome w then valOf w else raise Fail "Unrecognized Input")) o
                  (map wordFromString) o splitString) (valOf line)
        val newsize = if (not o isSome) size then
                        (Word.fromInt o length) ds
                      else if isSome size andalso
                           row <= valOf size andalso
                           (Word.fromInt o length) ds = valOf size then
                             valOf size
                      else raise Fail "Input line length mismatch"
        val newdata = if isSome data then valOf data else Vector.tabulate
                       ((Word.toInt o Word.div) (newsize*(newsize+0w1),0w2), fn _ => 0w0)
        val updated = addrow newdata row ds
      in
        readr (SOME updated) (SOME newsize) (row+0w1) input
      end
    end
  in
    fun readDistFile filename = let
      val file = TextIO.openIn filename
      val d = readr NONE NONE 0w0 file
    in
      TextIO.closeIn file;
      d
    end
  end

end
