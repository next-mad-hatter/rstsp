
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
    - tsplib i/o/conversion & benchmarks
    - check data licenses
    - polyml: smlofnj-lib license check
    - relaxations ?
* Report:
    - outline
    - writeup
* Research:
    - 3d euclidean applies?
    - relaxations
    - generator sandbox
* Source:
    - local search
    - sml/nj unresolved flex record in main ?
    - put src to dirs
    - when word is not enough: overwrap check / type option / replace
    - document code thoroughly
    - document/remove TODOs and FIXMEs
    - move structure-intern types to tsputils
    - shared library interface
    - options via record
    - add version info to executable/build
    - proper options parser
    - replace verbose option with quiet ?
    - plan/call for 0.1.0 rc1
    - concurrent performance/model: consult whom ?
    - doublekeymap -> sbgraph cleanup ?
    - vim sml indent mode
    - moscowml support ?
* Other:
    - concurrency: manticore/jocaml/mythryl/aliceml/clojure/akka,
                   linda/clotilde/pylinda etc
    - gains if any -> nim computation?
