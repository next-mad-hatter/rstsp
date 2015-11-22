
[//]: (# $Id$)
[//]: (# $Author$)
[//]: (# $Date$)
[//]: (# $Rev: 34 $)

* Repo:
    - automate create-polyml-smlnjlib scripts
    - complete the source readme
    - wiki / bug tracker ?
    - script via cmake ?
* Report:
    - writeup
    - sml support: can the pandoc -> rst way be pretty-fixed?
* Research:
    - ≥3D euclidean applies?
    - relaxations
    - generator sandbox
* Testing:
    - implement stats -> study iter convergence
    - implement -> test 3d-euclidean/manhattan instances
    - implement -> test starting tours options
    - tsplib med/large instances
    - profile everything
    - bar plots: combine patterns and color
    - investigate poly timeouts in random/hi (4k+5k)
    - measure memory usage (steady/memusg: how do we script this?)
    - batch runner: make progress reporting threaded, total <- sum of time_limits
    - batch runner: make progress bar optional
    - batch runner: write after each test + trap quit/term
    - batch runner: operate on file pairs + name batches
    - batch runner: rename timeout -> time_limit
    - batch runner: failed vs timed out stats
    - create_random_data (and more?): write <-> rescue unlink
    - mk_batches & mk_csv : factor out common code
    - use multiple random instances for target tests ?
    - plot hash collisions nrs ?
    - random data: compute hk bounds
    - test scripts in fresh clone
    - do we need merge xscales script ?
* Source:
    - profile iter+rot searches
    - iter + ff searches: return iterations results (for convergence studies) -> plot
    - add flip flop search
    - nearest neighbour/random/demidenko/relaxed supnick starters
    - sb iter search: 2*n+1 / even more permutations ?
    - options parser: http://mlton.org/FunctionalRecordUpdate
    - round to nearest integer as option
    - iter search (+1/n) time limits
    - shared lib interface: search transforms worth memory management hassle ?
    - word distance: wrapover cost check
    - compute tree width for info
    - try nearest neightbour / relaxed demidenko / relaxed supnick instances
    - tsplib input: support more formats
    - tsplib input: allow for empty & comment lines in data section
    - measure threaded storage + simplesearch performance
    - threaded rot/iter search
    - threaded: splay trees -> redblack trees ?
    - threaded: threadsafe lazy ?
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
