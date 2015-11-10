
[//]: (# $Id$)
[//]: (# $Author$)
[//]: (# $Date$)
[//]: (# $Rev: 34 $)

* Repo:
    - README.md: + contents info + pkging info + licensing info
    - src/rstsp/README.md: + contents info + licensing info + building info
    - wiki & bug tracker
    - plots clean script
    - script via cmake ?
* Testing:
    - batch runner: rename timeout -> time_limit
    - batch runner: operate on file pairs
    - batch runner: progress threaded, total <- sum of time_limits
    - batch runner: make progress bar optional
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
    - add needed non-random test data to repo
    - polyml: smlofnj-lib license check
    - relaxations ?
* Report:
    - writeup
    - sml support: can the pandoc -> rst way be pretty-fixed?
* Research:
    - ≥3D euclidean applies?
    - relaxations
    - generator sandbox
* Source:
    - *check*:
        - distmat.insert & results
        - runtime behaviour
        - hashtables hashing functions / size vs Splay/RBMaps ?
        - revert storage to maps?
        - vectors -> arrays necessary where ?
        - other storage changes necessary ?
    - lazy vs eager solution performance / memory / mlprof comparison
    - make lazy optional ?
    - threadsafe lazy ?
    - metric instances input + distance target type parameter
    - local search (pyr & bal)
    - test simplesearch under multimlton
    - measure thread-storage + simplesearch performance
    - long opts
    - reenable dotlog existence check ?
    - create changelog from TODO diffs ?
    - compute tree width for info ?
    - hardwired code creation (node type -> node types list)
    - mst tour / hk bounds
    - when word is not enough: overwrap check / type option / replace
    - shared library interface
    - put src to dirs
    - mlprof !
    - polyml.profile threaded
    - mlton/polyml make ?
    - add version info to executable/build
    - document code thoroughly
    - document/remove TODOs and FIXMEs
    - move structure-intern types to tsputils ?
    - options via record
    - proper options parser
    - plan/call for 0.1.0 rc1 when interfaces stabilize
    - concurrent performance/model: consult whom ?
    - doublekeymap -> sbgraph cleanup ?
    - vim sml indent mode
    - resurrect CML version ?
    - moscowml support ?
* Other:
    - concurrency: manticore/jocaml/mythryl/aliceml/clojure/akka,
                   linda/clotilde/pylinda etc
    - gains if any -> nim computation?
