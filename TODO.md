
[//]: (# $Id$)
[//]: (# $Author$)
[//]: (# $Date$)
[//]: (# $Rev: 34 $)

* Repo:
    - README.md: + contents info + pkging info + licensing info
    - src/rstsp/README.md: + contents info + licensing info + building info
    - wiki & bug tracker
    - plots clean script
* Testing:
    - batch runner: rename timeout -> time_limit
    - batch runner: operate on file pairs
    - batch runner: progress threaded, total <- sum of time_limits
    - batch runner: write after each test + trap quit/term
    - batch runner: failed vs timed out stats
    - batch runner: check size
    - test scripts in fresh clone
    - tsplib reader
    - tsp challenge testing
   - correctness tests
    - tsplib i/o & benchmarks
    - tsp challenge benchmarks
    - check data licenses
    - polyml: smlofnj-lib license check
    - relaxations ?
* Report:
    - writeup
* Research:
    - ≥3D euclidean applies?
    - relaxations
    - generator sandbox
    - fixed length exec generation
* Source:
    - *check*:
        - distmat.insert & results
        - runtime behaviour
        - hashtables hashing functions / size vs Splay/RBMaps ?
        - revert storage to maps?
        - vectors -> arrays necessary where ?
        - other storage changes necessary ?
    - make lazy optional (sbgraph, sblazygraph, etc)
    - lazy vs eager solution performance / memory / mlprof
    - threadsafe lazy ?
    - reenable dotlog existance check ?
    - create changelog from TODO diffs
    - compute tree width for info ?
    - tsblib points input with distance target type parameter
    - local search (pyr -> bal)
    - hardwired code creation (node type -> node types list)
    - mst tour
    - when word is not enough: overwrap check / type option / replace
    - shared library interface
    - put src to dirs
    - mlprof higher limits balanced search
    - polyml.profile threaded version
    - mlton/polyml make ?
    - add version info to executable/build
    - document code thoroughly
    - document/remove TODOs and FIXMEs
    - move structure-intern types to tsputils ?
    - options via record
    - proper options parser
    - plan/call for 0.1.0 rc1
    - concurrent performance/model: consult whom ?
    - doublekeymap -> sbgraph cleanup ?
    - vim sml indent mode
    - moscowml support ?
* Other:
    - concurrency: manticore/jocaml/mythryl/aliceml/clojure/akka,
                   linda/clotilde/pylinda etc
    - gains if any -> nim computation?
