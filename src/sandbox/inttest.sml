(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

val w = 0w0 - 0w1
val _ = print "sub ok\n"
val _ = print (Utils.wordToString w)
val _ = print "\n"
val _ = w + 0w1
val _ = print "add ok\n"
val i = (valOf Int.maxInt)
val _ = print (Int.toString i)
val _ = print "\n"
val _ = i+1
val _ = print "int add ok\n"

