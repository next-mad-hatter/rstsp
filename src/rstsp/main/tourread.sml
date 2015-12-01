(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature TOUR_READER =
sig

  val readTourFile : string -> word vector option

end

structure TourReader : TOUR_READER =
struct

  structure U = Utils

  datatype expect = CMD | DATA of int

  fun getExpLen CMD = raise Fail "tour reader paper error"
    | getExpLen (DATA i) = i

  val splitLine = String.tokens
    (fn c => c = #" " orelse c = #"\t" orelse c = #"\n" orelse c = #"\r")

  fun readData line_num expect tour' line =
  let
    fun err s = raise Fail (s ^ " at line " ^ U.wordToString line_num)
    val line' = splitLine line
    val len = length line'
    val tour = valOf tour'
    val _ = if len > getExpLen expect then err "unexpected data" else ()
    val _ = if len < 0 then err "unexpected empty line" else ()
    fun iter (_,[]) = ()
      | iter (pos, x::xs) =
        (
          case (x = "-1",pos = (Array.length tour) - 1) of
            (true, true) => Array.update (tour, pos, Array.sub (tour,0))
          | (false, _) =>
              let
                val x' = Int.fromString x
                val x'' = if isSome x' then valOf x' else err "bad tour index"
                val x''' = if x'' > 0 then Word.fromInt (x''-1) else err "bad tour index"
              in
                Array.update (tour, pos, x''');
                iter (pos+1, xs)
              end
          | (_,_) => raise Fail "unexpected -1"
        )
  in
    iter (Array.length tour - getExpLen expect, line');
    (DATA (getExpLen expect - len), SOME tour)
  end

  fun readCmd line_num exp tour line =
  let
    val splitCmd = String.tokens
      (fn c => c = #" " orelse c = #"\t" orelse c = #"\n" orelse c = #"\r" orelse c = #":")
    val cmd = splitCmd line
    fun err msg = raise Fail (msg ^ " at line " ^ U.wordToString line_num)
  in
    case length cmd > 0 of
      false => err ("unknown command " ^ line)
    | _ => case (hd cmd, tl cmd) of
             ("DIMENSION", [m]) =>
               (
                 case (Int.fromString m, tour) of
                   (NONE,_) => err "bad dimension"
                 | (SOME m',NONE) => (CMD, SOME (Array.array (m'+1,0w0)))
                 | (SOME m',SOME a) => if Array.length a = m'+1 then (CMD,tour) else err "conflicting dimension"
               )
           | ("DIMENSION", _) => err "dimension expected"
           | ("TYPE", ["TOUR"]) => (CMD,tour)
           | ("TYPE", l) => err ("unsupported tour type (" ^ (String.concatWith " " l) ^ ")")
           | ("TOUR_SECTION", []) =>
               (
                 case tour of
                   SOME a => (DATA (Array.length a),tour)
                  | _ => err "expecting dimension"
               )
           | ("TOUR_SECTION", _) => err "stale input"
           | _ => (exp,tour)
  end

  fun readLine input line_num exp tour =
  let
    val line = TextIO.inputLine input
  in
    case (line, exp) of
      (_, DATA 0) => tour
    | (NONE, _) => raise Fail "unexpected end of file"
    | (SOME l, _) =>
        let
          val line_num' = line_num+0w1
          val l' = (String.map Char.toUpper) l
        in
          case (U.stripWS l',exp) of
            ("",_) => readLine input line_num' exp tour
          | ("EOF",_) => raise Fail ("unexpected EOF token at line " ^ U.wordToString line_num')
          | (_,CMD) =>
              let
                val (e,t) = readCmd line_num' exp tour l'
              in
                readLine input line_num' e t
              end
          | (_,DATA _) =>
              let
                val (e,t) = readData line_num' exp tour l'
              in
                readLine input line_num' e t
              end
        end
  end

  fun readTourFile filename =
  let
    val file = if filename = "-" then TextIO.stdIn else TextIO.openIn filename
    fun closeIn () = if filename = "-" then () else TextIO.closeIn file
    val tour = (readLine file 0w0 CMD NONE)
                 handle Fail e => (closeIn (); U.printErr e; NONE)
    val _ = closeIn ()
  in
    case tour of
      SOME t => SOME (Array.vector t)
    | NONE => NONE
  end

end
