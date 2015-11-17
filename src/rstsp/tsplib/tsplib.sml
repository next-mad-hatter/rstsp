(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure U = Utils

signature NUMERIC =
sig
  type num
  val + : num * num -> num
  val zero : num
  val compare : num * num -> order
  val toString : num -> string
end

structure RealNum : NUMERIC =
struct
  type num = Real.real
  val op+ = Real.+
  val zero = 0.0
  val compare = Real.compare
  val toString = Real.toString
end

structure WordNum : NUMERIC =
struct
  type num = Word.word
  val op+ = Word.+
  val zero = 0w0
  val compare = Word.compare
  val toString = U.wordToString
end

signature DISTANCE =
sig
  structure DistType : NUMERIC
  type dist
  val getDist : dist -> word * word -> DistType.num
end

fun flatCoor (row:word,col:word) =
  if row >= col then Word.toInt (Word.div (row*(row+0w1),0w2) + col)
                else flatCoor (col,row)

structure NatDist : DISTANCE =
struct
  structure DistType = WordNum
  type dist = word vector
  fun getDist v (i,j) = Vector.sub (v, flatCoor (i,j))
end

structure EuclDist : DISTANCE =
struct
  structure DistType = RealNum
  type dist = real vector * real vector
  fun getDist (xs,ys) (i,j) =
  let
    val dx = Vector.sub (xs, Word.toInt i) - Vector.sub (xs, Word.toInt j)
    val dy = Vector.sub (ys, Word.toInt i) - Vector.sub (ys, Word.toInt j)
  in
    Math.sqrt (dx*dx+dy*dy)
  end
end

datatype tsplib_dist = EUCL_DIST of real vector * real vector
                     | NAT_DIST of word vector
                     | ERR of string

datatype tsplib_dist' = EUCL_DIST' of real array * real array
                     | NAT_DIST' of word array
                     | ERR' of string

datatype edge_weight_type = EXPLICIT
                          | EUC_2D

datatype edge_weight_format = FUNCTION | FULL_MATRIX
                            | UPPER_DIAG_ROW | UPPER_ROW
                            | LOWER_DIAG_ROW | LOWER_ROW

datatype expect = CMD | DATA | DONE

val splitCmd = String.tokens (fn c => c = #" " orelse c = #"\t" orelse c = #"\n" orelse c = #"\r" orelse c = #":")

val splitLine = String.tokens (fn c => c = #" " orelse c = #"\t" orelse c = #"\n" orelse c = #"\r")

fun readEucLine (line_num, pos, (xs,ys), line) =
let
  fun err () = raise Fail ("bad coordinates at line " ^ U.wordToString line_num)
  val line' = splitLine line
  val _ = if length line' <> 3 then err () else ()
  val x = Real.fromString (List.nth (line',1))
  val y = Real.fromString (List.nth (line',2))
in
  case (x,y) of
    (SOME x', SOME y') => (Array.update (xs, pos, x'); Array.update (ys, pos, y'))
  | _ => err ()
end

(* TODO: UPPER_DIAG_ROW + no-diag? *)
fun readNatLine (line_num, dim, to_read, weight_format, data, line) =
let
  fun err msg = raise Fail (msg ^ " at line " ^ U.wordToString line_num)
  val line' = splitLine line
  val len = Word.fromInt (length line')
  val _ = if len > to_read then err "unexpected data" else ()
  val _ = if len < 0w1 then err "unexpected empty line" else ()
  val done = if len = to_read then DONE else DATA
  val coor = case weight_format of
               LOWER_DIAG_ROW => (fn n => Word.toInt (Word.div (dim*(dim+0w1),0w2) - n))
             | FULL_MATRIX => (fn n =>
                 let
                   val n' = dim*dim - n
                   val i = Word.mod(n', dim)
                   val j = Word.div(n', dim)
                 in
                   flatCoor (i,j)
                 end
                 )
             | _ => raise Fail "not implemented"
  fun iter (pos, []) = ()
    | iter (pos, x::xs) =
      let
        val x' = U.wordFromString x
        val x'' = if isSome x' then valOf x' else err "bad entry"
        val _ = case weight_format of
                  FULL_MATRIX =>
                  let
                    val y = Array.sub (data, coor pos)
                  in
                    if y = 0w0 orelse y = x'' then () else err "not a symmetric instance"
                  end
                | _ => ()
        val _ = Array.update (data, coor pos, x'')
      in
        iter (pos-0w1, xs)
      end
  val _ = iter (to_read, line')
in
  (done, to_read-len)
end

fun readData (line_num, (dim, weight_type, weight_format), to_read, data) line =
  case weight_type of
    SOME EUC_2D =>
      let
        val data' = case data of
                      NONE => (Array.array (Word.toInt dim, 0.0),
                               Array.array (Word.toInt dim, 0.0))
                    | SOME (EUCL_DIST' (xs,ys)) => (xs,ys)
                    | _ => raise Fail "readData/Eucl error"
        val _ = readEucLine (line_num, Word.toInt (dim-to_read), data', line)
        val expect = if to_read = 0w1 then (DONE,0w0) else (DATA, to_read-0w1)
      in
        (line_num, (SOME dim, weight_type, weight_format), expect, SOME (EUCL_DIST' data'))
      end
  | SOME EXPLICIT =>
      let
        val data' = case data of
                      NONE => Array.array (Word.toInt (Word.div (dim*(dim+0w1),0w2)),0w0)
                    | SOME (NAT_DIST' ds) => ds
                    | _ => raise Fail "readData/Expl error"
        val expect = readNatLine (line_num, dim, to_read, valOf weight_format, data', line)
      in
        (line_num, (SOME dim, weight_type, weight_format), expect, SOME (NAT_DIST' data'))
      end
  | _ => raise Fail "readData error"

fun readCmd (line_num, (dim, weight_type, weight_format)) line =
let
  val cmd = splitCmd line
  fun err msg = raise Fail (msg ^ " at line " ^ U.wordToString line_num)
in
  case length cmd > 0 of
    false => err "unexpected :"
  | _ => case (hd cmd, tl cmd) of
           ("DIMENSION", [m]) =>
             (
               case (U.wordFromString m, dim) of
                 (NONE,_) => err "bad dimension"
               | (SOME m',NONE) => (line_num, (SOME m', weight_type, weight_format), (CMD,0w1), NONE)
               | _ => err "stale dimension"
             )
         | ("DIMENSION", _) => err "dimension expected"
         | ("TYPE", ["TSP"]) => (line_num, (dim, weight_type, weight_format), (CMD,0w1), NONE)
         | ("TYPE", l) => err ("unsupported data type" ^ String.concatWith " " l)
         | ("EDGE_WEIGHT_TYPE", ["EXPLICIT"]) => (line_num, (dim, SOME EXPLICIT, weight_format), (CMD,0w1), NONE)
         | ("EDGE_WEIGHT_TYPE", ["EUC_2D"]) =>   (line_num, (dim, SOME EUC_2D,   weight_format), (CMD,0w1), NONE)
         | ("EDGE_WEIGHT_TYPE", []) => err "edge weight type expected"
         | ("EDGE_WEIGHT_TYPE", _) => err "unsupported edge weight type"
         | ("EDGE_WEIGHT_FORMAT", ["FUNCTION"]) =>       (line_num, (dim, weight_type, SOME FUNCTION),       (CMD,0w1), NONE)
         | ("EDGE_WEIGHT_FORMAT", ["FULL_MATRIX"]) =>    (line_num, (dim, weight_type, SOME FULL_MATRIX),    (CMD,0w1), NONE)
         | ("EDGE_WEIGHT_FORMAT", ["UPPER_DIAG_ROW"]) => (line_num, (dim, weight_type, SOME UPPER_DIAG_ROW), (CMD,0w1), NONE)
         | ("EDGE_WEIGHT_FORMAT", ["UPPER_ROW"]) =>      (line_num, (dim, weight_type, SOME UPPER_ROW),      (CMD,0w1), NONE)
         | ("EDGE_WEIGHT_FORMAT", ["LOWER_DIAG_ROW"]) => (line_num, (dim, weight_type, SOME LOWER_DIAG_ROW), (CMD,0w1), NONE)
         | ("EDGE_WEIGHT_FORMAT", ["LOWER_ROW"]) =>      (line_num, (dim, weight_type, SOME LOWER_ROW),      (CMD,0w1), NONE)
         | ("EDGE_WEIGHT_FORMAT", []) => err "edge weight format expected"
         | ("EDGE_WEIGHT_FORMAT", _) => err "unsupported edge weight format"
         | ("NODE_COORD_SECTION", []) =>
             (
               case (dim, weight_type, weight_format = SOME FUNCTION orelse weight_format = NONE) of
                  (SOME n, SOME EUC_2D, true) => (line_num, (dim, weight_type, weight_format), (DATA,n), NONE)
                | _ => err "unexpected coordinates section"
             )
         | ("NODE_COORD_SECTION", _) => err "stale input"
         | ("EDGE_WEIGHT_SECTION", []) =>
             (
               case (dim, weight_type, weight_format) of
                 (SOME n, SOME EXPLICIT, SOME FULL_MATRIX) =>    (line_num, (dim, weight_type, weight_format), (DATA,n*n), NONE)
               | (SOME n, SOME EXPLICIT, SOME UPPER_DIAG_ROW) => (line_num, (dim, weight_type, weight_format), (DATA, Word.div (n*(n+0w1),0w2)), NONE)
               | (SOME n, SOME EXPLICIT, SOME LOWER_DIAG_ROW) => (line_num, (dim, weight_type, weight_format), (DATA, Word.div (n*(n+0w1),0w2)), NONE)
               | (SOME n, SOME EXPLICIT, SOME UPPER_ROW) =>      (line_num, (dim, weight_type, weight_format), (DATA, Word.div (n*(n-0w1),0w2)), NONE)
               | (SOME n, SOME EXPLICIT, SOME LOWER_ROW) =>      (line_num, (dim, weight_type, weight_format), (DATA, Word.div (n*(n-0w1),0w2)), NONE)
               | _ => raise Fail "readCmd error"
             )
         | ("EDGE_WEIGHT_SECTION", _) => err "stale input"
         | _ => (line_num, (dim, weight_type, weight_format), (CMD,0w1), NONE)
end

fun readTSP input (line_num, (dim, weight_type, weight_format), (exp, count), data) =
let
  val line = TextIO.inputLine input
in
  case (line, exp) of
    (_, DONE) => data
  | (NONE, _) => raise Fail "unexpected end of file"
  | (SOME l, _) =>
      let
        val line_num' = line_num+0w1
        val l' = (String.map Char.toUpper) l
      in
        case (U.stripWS l',exp) of
          ("",_) => readTSP input (line_num', (dim, weight_type, weight_format), (exp, count), data)
        | ("EOF",_) => raise Fail ("unexpected EOF token at line " ^ U.wordToString line_num')
        | (_,CMD) => readTSP input (readCmd (line_num', (dim, weight_type, weight_format)) l')
        | (_,DATA) => readTSP input (readData (line_num', (valOf dim, weight_type, weight_format), count, data) l')
        | _ => raise Fail "not implemented"
      end
end

fun readFile filename =
let
  val file = TextIO.openIn filename
  val dist = readTSP file (0w0, (NONE, NONE, NONE), (CMD,0w1), NONE)
               handle Fail e => (TextIO.closeIn file; SOME (ERR' e))
  val _ = TextIO.closeIn file
in
  case dist of
    SOME (NAT_DIST' x) => NAT_DIST (Array.vector x)
  | SOME (EUCL_DIST' (x,y)) => EUCL_DIST (Array.vector x, Array.vector y)
  | SOME (ERR' s) => ERR s
  | NONE => ERR "tsplib reader error"
end
