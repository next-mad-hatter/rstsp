
[//]: (#  $Id$)
[//]: (# $Author$)
[//]: (# $Date$)
[//]: (# $Rev: 34 $)

* Repo:
    - README.md: + contents info + pkging info + licensing info
    - src/rstsp/README.md: + contents info + licensing info + building info
    - wiki & bug tracker
* Testing:
    - scripted statistics collection
      (version, algorithm/limit -> node types, store size, running time, result etc)
    - correctness tests
    - tsplib i/o & benchmarks
    - check data licenses
    - polyml: smlofnj-lib license check
    - relaxations ?
* Report:
    - writeup
* Research:
    - 3d euclidean applies?
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
    - local search (pyr -> bal)
    - mst tour
    - options: algorithm ~= prefx
    - tsblib/euclidean input
    - when word is not enough: overwrap check / type option / replace
    - shared library interface
    - mlton/polyml make ?
    - add version info to executable/build
    - polyml/threaded: timer per cpu
    - sml/nj: "unresolved flex record in main" bug?
    - put src to dirs
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
