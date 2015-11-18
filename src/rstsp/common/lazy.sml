(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

(**
 * Suspended & then memoized evaluation.
 *)
signature LAZY =
sig
  val susp: (unit -> 'a) -> unit -> 'a
end

structure Lazy : LAZY =
struct

  datatype 'a susp = DONE of 'a | BOXED of (unit -> 'a) | FAILED of exn

  fun eval mem =
    case !mem of
      BOXED f =>
      let
        val r  = f ()
          handle e => (mem := FAILED e; raise e)
      in
        mem := DONE r;
        r
      end
    | DONE r => r
    | FAILED e => raise e

  fun susp f =
  let
    val mem = ref (BOXED f)
  in
    fn () => eval mem
  end

end
