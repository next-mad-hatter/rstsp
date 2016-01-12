
[//]: (# $Id$)
[//]: (# $Author$)
[//]: (# $Date$)
[//]: (# $Rev: 34 $)

* Repo:
    - rename rstsp -> p4/psb/........tsp
    - docs/src/etc: check balanced/strongly balanced naming
    - automate create-polyml-smlnjlib scripts
    - complete the source readme
    - wiki / bug tracker ?
    - script via cmake ?
    - report: "build what" option
* Report:
    - TUG logo
    - writeup (see FIXMEs)
    - compute tree width (bfs?) for info
    - bar plots: combine patterns and color
    - metapost vs tikz vs asymptote ?
    - gnuplot vs matplotlib vs pgf ?
    - dot2tex ?
    - sml support: can the pandoc -> rst way be pretty-fixed?
* Slides:
    - throw out things
    - complete plots & illustrations
    - rerun tests with proper cooling
    - gnuplot: better captions
    - add overlays
    - graphviz font ?
    - handouts ?
    - second slides set with exact definitions ?
    - tsplib results: histboxplot with outliers -- matplotlib/bokeh/ggplot/vincent/seaborn ?
    - tug: aspect ratio, vga/dp (,wlan) available ?
* Research:
    - sb : better permutations?
    - study iter convergence
    - preprocessing? (~rs-sort bad)
    - ≥3D euclidean applies?
    - relaxations
    - generator sandbox
* Testing:
    - test on rs instances
    - tsplib med/large instances
    - implement -> test 3d-euclidean/manhattan instances
    - implement -> test atsp instances
    - combine trampoline w/ other heuristics ?
    - compare to concorde/lkh on random instances
    - study sb node size effect
    - investigate polyml timeouts in random/hi (4k+5k)
    - measure memory usage (steady/memusg: how do we script this?)
    - plot hash collisions nrs ?
* Scripts:
    - batch runner: make progress reporting threaded, total <- sum of time_limits
    - batch runner: make progress bar optional
    - batch runner: operate on file pairs + name batches
    - batch runner: write after each test / trap quit/term ?
    - batch runner: failed vs timed out stats
    - batch runner: rename timeout -> time_limit
    - create_random_data (and more?): write <-> rescue unlink
    - mk_batches & mk_csv : factor out common code
    - random data: compute hk bounds ?
    - do we need merge xscales script for gnuplot?
    - sometimes: test scripts in fresh clone
* Source:
    - dotlog: invalid dir -> catch exception
    - pyrgraph: test & cleanup symmetric case
    - default searches: cleanup sb permutations
    - implement bfs
    - make dotfile optional parameter to simplesearch (=dfs) & bfs
    - rot search: -a = -r -> ?
    - belperm: dedicated implementation ?
    - balanced: dedicated implementation ?
    - implement atsp ?
    - flip flop search: ad -> ad+full (min_rot option)
    - profile
    - make stats / search return type polymorphic
    - iter searches: implement time limits
    - factor out sb_shuffle, rename to supnick_perm?
    - factor default+threaded searches?
    - pyrrot + sbrot flip flop
    - add rounding to nearest integer as binarys option (now available only per REPL)
    - flipflop( flipflop(ad, pyr), pyrrot ) ?
    - iter + ff searches: return iterations results rather than print to stderr -> progress feedback ?
    - tsplib input: support more formats
    - tsplib input: allow for empty & comment lines in data section
    - branch cutting ?
    - options parser: http://mlton.org/FunctionalRecordUpdate
    - librstsp: adaptive search rate & permutations as function ptrs ?
    - shared lib interface: search transforms worth memory management hassle ?
    - try threaded storage + simplesearch
    - threaded hashtable store
    - threaded rot/iter search ?
    - threaded: splay trees -> redblack trees ?
    - threaded: threadsafe lazy ?
    - threaded: polyml.profile
    - test simplesearch under multimlton
    - misleading timings / timer stop points ?
    - hardwired code creation (node type -> node types list)
    - implement doublekeymap & move the housekeeping from sbgraph
    - implement mst tour / bounds computations ?
    - use mlton/polyml make ?
    - add version info to executable/build ?
    - plan/call for 0.1.0 rc1 when interfaces stabilize
    - create changelog/release notes or stick to todo list after that ?
    - concurrent performance/model ?
    - resurrect CML version ?
    - moscowml support ?
* Other:
    - create better vim sml indent mode ?
    - concurrency: manticore/jocaml/mythryl/aliceml/clojure/akka,
                   linda/clotilde/pylinda etc
    - gains if any -> nim computation?
