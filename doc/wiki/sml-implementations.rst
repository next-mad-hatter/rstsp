================ ======== ========= ======= ============ ================
 Feature          SML/NJ   Poly/ML   MLton   multiMLton   multiMLton-ubm
================ ======== ========= ======= ============ ================
 REPL              Yes      Yes       No      No           No
 Compiler           ?       Yes       Yes     Yes[4]       Yes/?[6]
 Cross-compiler     ?        ?        Yes      ?            ?
 FFI                ?       ?/Yes     Yes      ?            ?
 SMP support       No/?     Yes       No      Yes/?[5]      ?
 CML               Yes[1]   No[2]     Yes     ?[5]          ?
 smlnj-lib         Yes      No[3]     Yes     Yes           ?
---------------- -------- --------- ------- ------------ ----------------
 Support           Yes      Yes       Yes     Dropped      Dropped
================ ======== ========= ======= ============ ================

[1] CML implementation under SML/NJ has some I/O related quirks.
[2] Poly/ML has a multithreading library.
[3] At time of writing, smlnj-lib can be added to Poly/ML
from MLton with minimal effort.
[4] multiMLton would require patching to build under MLton-2013 (build features cm-files).
[5] multiMLton features its own CML implementation -- Pacml -- but
compiled executables would deadlock with @MLton number-processors > 1
on our system.
[6] multiMLton-ubm compiled executables would crash on our system.

CML support was dropped subsequently.
