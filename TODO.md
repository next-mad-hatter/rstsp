
[//]: (# $Id$)
[//]: (# $Author$)
[//]: (# $Date$)
[//]: (# $Rev: 34 $)

* Repo:
    - rename rstsp -> p4/psb/........tsp
    - automate create-polyml-smlnjlib scripts
    - complete the source readme
    - wiki / bug tracker ?
    - script via cmake ?
* Report:
    - writeup
    - compute tree width for info
    - bar plots: combine patterns and color
    - metapost vs tikz vs asymptote ?
    - gnuplot vs matplotlib vs pgf ?
    - sml support: can the pandoc -> rst way be pretty-fixed?
* Research:
    - sb : better permutations?
    - study iter convergence
    - preprocessing? (~rs-sort bad)
    - ≥3D euclidean applies?
    - relaxations
    - generator sandbox
* Testing:
    - test tour save/load
    - test on rs + monge instances
    - implement -> test 3d-euclidean/manhattan instances
    - tsplib med/large instances
    - study sb node size effect
    - investigate poly timeouts in random/hi (4k+5k)
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
    - rot search: -a = -r -> ?
    - profile
    - belperm: dedicated implementation ?
    - balanced: dedicated implementation ?
    - dotfile & stats wish -> simplesearch optional option ?
    - make stats / search return type polymorphic
    - iter searches time limits
    - flip flop search: ad -> ad+full (min_rot option)
    - factor out sb_shuffle
    - pyrrot + sbrot flip flop
    - round to nearest integer as option
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
