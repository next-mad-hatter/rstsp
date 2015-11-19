
[//]: (# $Id$)
[//]: (# $Author$)
[//]: (# $Date$)
[//]: (# $Rev: 34 $)

* Repo:
    - automate create-polyml-smlnjlib scripts
    - script via cmake ?
    - wiki / bug tracker ?
* Report:
    - writeup
    - sml support: can the pandoc -> rst way be pretty-fixed?
* Research:
    - ≥3D euclidean applies?
    - relaxations
    - generator sandbox
* Testing:
    - benchmark: tsplib
    - benchmark: dimacs
    - benchmark: vlsi
    - investigate the single poly timeout in random/hi (4k) batch run ?
    - measure memory usage (steady/memusg: how do we script this?)
    - better iter search testing
    - batch runner: rename timeout -> time_limit
    - batch runner: operate on file pairs
    - batch runner: progress threaded, total <- sum of time_limits
    - batch runner: make progress bar optional
    - batch runner: write after each test + trap quit/term
    - batch runner: failed vs timed out stats
    - batch runner: check size / validity if present
    - batch runner: named batches
    - mk_batches: factor out common code
    - create_random_data (and more?): write <-> rescue unlink
    - use multiple random instances for target tests
    - plot hash collisions nrs ?
    - glpk/hk bounds comparison
    - test scripts in fresh clone
* Source:
    - threaded version: finish port
    - add:
            - round to nearest integer option?
            - flip flop search
            - iter/rot searches: return list of target values
            - sb iter search: two reorderings?
            - iter search (+1/n) time limits
            - shared library interface
    - complete source readme
    - compute tree width for info
    - word distance: wrapover check cost ?
    - tsplib input: support more formats
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
    - options parser: http://mlton.org/FunctionalRecordUpdate ?
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
