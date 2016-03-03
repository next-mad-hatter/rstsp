
[//]: (# $Id$)
[//]: (# $Author$)
[//]: (# $Date$)
[//]: (# $Rev: 34 $)

* Repo:
    - readme: update test time info
    - rename rstsp -> p4/psb/........tsp
    - docs/src/etc: check balanced/strongly balanced naming
    - automate create-polyml-smlnjlib scripts
    - complete the source readme
    - wiki / bug tracker ?
    - script via cmake ?
    - report: "build report/slides/handouts" option
* Report:
    - authors format check
    - TUG logo ?
    - index ?
    - (also in slides: add a frame to show partial tour in illustration of s.b. options)
    - sml support: can the pandoc -> rst way be pretty-fixed?
    - metapost plots: parse outputtemplate instead of fake outputformat
    - metapost plots: include directly in report?
* Slides:
    - add sample descent along sb tree from report
    - plots: make color dependent on handout/present mode
    - persistent handouts/notes build ?
    - add overlays ?
* Research:
    - sb : better rotations/flowers (depends on node size?) ?
    - study iter convergence
    - preprocessing? (~rs-sort bad)
    - ≥3D euclidean applies?
    - relaxations
    - generator sandbox
* Testing:
    - interleaved supnick: back transform vs none ?
    - add a larger "pyr vs s.b. vs flipflop" test -> plot -> report/slides/readme
    - test on rs instances
    - benchmark more/larger tsplib/vlsi/... instances
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
    - rework comments to reflect report terminology
    - precompute flowers (rotations set)
    - implement bfs
    - implement single tour reconstruction & compare vs lazy evaluation
    - make flower depend on s.b. node size -> experiment ?
    - dotlog: invalid dir -> catch exception
    - make dotfile optional parameter to simplesearch (=dfs) & bfs
    - rot search: -a = -r -> ?
    - implement atsp ?
    - flip flop search: ad -> ad+full (min_rot option)
    - profile
    - make stats / search return type polymorphic
    - iter searches: implement time limits
    - factor out sb_shuffle, rename to supnick_perm?
    - update default searches in experimental search
    - factor default+threaded searches?
    - pyrrot + sbrot flip flop
    - add rounding to nearest integer as binarys option (now available only per REPL)
    - flipflop( flipflop(ad, pyr), pyrrot ) ?
    - iter + ff searches: return iterations results rather than print to stderr -> progress feedback ?
    - tsplib input: support more formats
    - tsplib input: allow for empty & comment lines in data section
    - branch cutting ?
    - options parser: http://mlton.org/FunctionalRecordUpdate
    - librstsp: adaptive search flower growth rate & permutations as function ptrs ?
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
    - belperm: dedicated implementation ?
    - balanced: dedicated implementation for each maximum node size M?
* Other:
    - create better vim sml indent mode ?
    - concurrency: manticore/jocaml/mythryl/aliceml/clojure/akka,
                   linda/clotilde/pylinda etc
    - gains if any -> nim computation?
