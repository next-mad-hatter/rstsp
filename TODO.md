
[//]: (# $Id$)
[//]: (# $Author$)
[//]: (# $Date$)
[//]: (# $Rev: 34 $)

* Repo:
    - README.md: repo info
    - src/rstsp/README.md: src info
    - add fetch-data & create-polyml-smlnjlib scripts
    - plots clean script
    - script via cmake ?
    - wiki / bug tracker ?
* Testing:
    - why the single poly timeout in batch run ?
    - add long/2-4 test to test new hasher
    - batch runner: rename timeout -> time_limit
    - batch runner: operate on file pairs
    - batch runner: progress threaded, total <- sum of time_limits
    - batch runner: make progress bar optional
    - batch runner: write after each test + trap quit/term
    - batch runner: failed vs timed out stats
    - batch runner: check size
    - batch runner: named batches
    - mk_batches: factor out common code
    - random matrix: create upper/lower diag matrix only
    - create_random_data (and more?): write <-> rescue unlink
    - measure memory usage (memusg: how do we script this?)
    - test scripts in fresh clone
    - tsp challenge benchmarks
    - tsplib i/o & benchmarks
    - plot hash collisions nrs ?
    - correctness tests ?
* Report:
    - writeup
    - sml support: can the pandoc -> rst way be pretty-fixed?
* Research:
    - ≥3D euclidean applies?
    - relaxations
    - generator sandbox
* Source:
    - refactor:
            - return tour length -- for n-local search
            - dist target type -- for metric input
            - src description, combthrough & dirs tree structure
    - add:
            - [threaded] n-local search -> to settings ?  terminate when ?
            - metric instances input + distance target type parameter
            - upper/lower diag input
            - shared library interface
    - better sb hashing function / types-map?
    - add hashing function option ?
    - revert storage to maps?
    - measure thread-storage + simplesearch performance
    - lazy vs eager solution performance / memory / mlprof comparison
    - threadsafe lazy ?
    - test simplesearch under multimlton
    - vectors -> arrays necessary where ?
    - other storage changes necessary ?
    - misleading timings / timer stop points
    - reenable dotlog existence check ?
    - compute tree width for info ?
    - hardwired code creation (node type -> node types list)
    - mst tour / hk bounds
    - when word is not enough: overwrap check / type option / replace
    - mlprof !
    - polyml.profile threaded
    - mlton/polyml make ?
    - add version info to executable/build ?
    - create changelog from TODO diffs ?
    - document/remove TODOs and FIXMEs
    - move structure-intern types to tsputils ?
    - options via record ?
    - proper options parser ?
    - plan/call for 0.1.0 rc1 when interfaces stabilize
    - concurrent performance/model: consult whom ?
    - doublekeymap -> sbgraph cleanup ?
    - rename max_int ?
    - vim sml indent mode
    - resurrect CML version ?
    - moscowml support ?
* Other:
    - concurrency: manticore/jocaml/mythryl/aliceml/clojure/akka,
                   linda/clotilde/pylinda etc
    - gains if any -> nim computation?
