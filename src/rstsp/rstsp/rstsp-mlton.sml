(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure Settings: SETTINGS = struct
  val getCmdName = SMLofNJ.getCmdName
  val getArgs = SMLofNJ.getArgs
end

structure Main = MainFn(Settings)

val _ = Main.main ()
