(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(*
 * Poly/ML defines main as entry point,
 * whereas MLton simply evaluates this.
 *)

val _ = main ()

(*
val quantum = SOME (Time.fromMilliseconds 10)
val _ = RunCML.doit (fn () =>
  (
    main ();
    RunCML.shutdown OS.Process.success;
    ()
  ), quantum)
*)

