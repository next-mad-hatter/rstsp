
[//]: (# $Id$)
[//]: (# $Author$)
[//]: (# $Date$)
[//]: (# $Rev: 34 $)

* Repo:
    - wiki / bug tracker ?
    - script via cmake ?
    - automate create-polyml-smlnjlib scripts
    - complete the source readme
* Report:
    - writeup
    - sml support: can the pandoc -> rst way be pretty-fixed?
* Research:
    - ≥3D euclidean applies?
    - relaxations
    - generator sandbox
* Testing:
    - benchmark: vlsi
    - bar plots: combine patterns and color
    - investigate poly timeouts in random/hi (4k+5k)
    - measure memory usage (steady/memusg: how do we script this?)
    - better iter search testing
    - batch runner: make progress reporting threaded, total <- sum of time_limits
    - batch runner: make progress bar optional
    - batch runner: write after each test + trap quit/term
    - batch runner: operate on file pairs + name batches
    - batch runner: rename timeout -> time_limit
    - batch runner: failed vs timed out stats
    - create_random_data (and more?): write <-> rescue unlink
    - random matrix creation: add 3d metric instances
    - mk_batches & mk_csv : factor out common code
    - use multiple random instances for target tests
    - plot hash collisions nrs ?
    - random data: compute hk bounds
    - test scripts in fresh clone
    - do we need merge xscales script ?
* Source:
    - add flip flop search
    - iter/rot searches: return iterations results (for convergence studies)
    - sb iter search: two reorderings?
    - shared library interface
    - options parser: http://mlton.org/FunctionalRecordUpdate
    - round to nearest integer option
    - iter search (+1/n) time limits
    - word distance: wrapover cost check
    - compute tree width for info
    - tsplib input: support more formats
    - tsplib input: allow for empty & comment lines in data section
    - mlprof
    - measure threaded storage + simplesearch performance
    - threaded rot/iter search
    - threaded: splay trees -> redblack trees !
    - threaded: readsafe lazy ?
    - threaded: polyml.profile
    - test simplesearch under multimlton
    - misleading timings / timer stop points
    - hardwired code creation (node type -> node types list)
    - implement doublekeymap & move the housekeeping from sbgraph
    - when word is not enough: overwrap check / type option / replace
    - branch cutting ?
    - mst tour / hk bounds
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
