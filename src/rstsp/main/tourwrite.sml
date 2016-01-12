(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

signature TOUR_WRITER =
sig

  val writeTourFile : word -> string -> word vector -> unit

end

structure TourWriter : TOUR_WRITER =
struct

  structure U = Utils

  fun writeTour base out tour =
  let
    val _ = if Vector.sub (tour,0) = Vector.sub (tour,Vector.length tour - 1) then () else raise Fail "unclosed tour"
    fun prn s = TextIO.output (out,s ^ "\n")
  in
      prn "TYPE : TOUR";
      prn ("DIMENSION " ^ (Int.toString (Vector.length tour - 1)));
      prn "TOUR_SECTION";
      Vector.appi (fn (i,x) => prn (if i = Vector.length tour - 1 then "-1" else U.wordToString (x+base))) tour;
      prn "EOF"
  end

  fun writeTourFile base filename tour =
  let
    val file = TextIO.openOut filename
    fun closeOut () = TextIO.closeOut file
    val _ = (writeTour base file tour)
              handle e => (closeOut (); raise e)
    val _ = closeOut ()
  in
    ()
  end

end
