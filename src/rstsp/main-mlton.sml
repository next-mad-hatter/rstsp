(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure Settings: SETTINGS = struct
  structure PyrSearch : TSP_SEARCH = SimpleSearchFn(
    struct structure Graph = PyrGraph; structure Store = MapStore(PyrGraph) end)
  structure SBSearch : TSP_SEARCH = SimpleSearchFn(
    struct structure Graph = SBGraph; structure Store = MapStore(SBGraph) end)
  val getArgs = SMLofNJ.getArgs
end

structure Main = MainFn(Settings)

val _ = Main.main ()
