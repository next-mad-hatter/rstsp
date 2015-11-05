
#
# $Id$
# $Author$
# $Date$
# $Rev: 34 $
#

* Repo:
  - README.md: + contents info + pkging info + licensing info + design info
  - src/rstsp/README.md: + licensing info + building info
  - wiki & bug tracker
* Source:
  - options parsing & dot log as option
  - local search
  - when word is not enough: overwrap check / type option / replace
  - document code thoroughly
  - document/remove TODOs and FIXMEs
  - move structure-intern types to tsputils
  - shared library interface
  - plan/call for 0.1.0rc1
  - concurrent performance/model: consult whom ?
  - doublekeymap -> sbgraph cleanup ?
  - vim sml indent mode
* Testing:
  - scripted statistics collection
    (version, algorithm/limit -> node types, store size, running time, result)
  - correctness tests
  - tsplib i/o/conversion & benchmarks
  - check data licenses
  - polyml: smlofnj-lib license check
  - relaxations ?
* Other:
  - concurrency: manticore/jocaml/mythryl/aliceml/clojure/akka,
                 linda/clotilde/pylinda etc
  - gains if any -> nim computation?
* RS:
  - 3d euclidean applies?
  - relaxations
  - generator sandbox
* Report:
  - outline
  - writeup
