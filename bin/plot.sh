#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`
cd "${PROJ_DIR}/plot" || exit 1
mkdir -p build || exit 1

. "${PROJ_DIR}"/bin/check_ruby.sh

./plot_num_types.gpi

./mk_csv_random.rb
./plot_random.gpi

./mk_csv_tsplib.rb
./plot_tsplib.gpi

../src/rstsp/build/rstsp.mlton -o /dev/null -t p ../test/data/random/random.5 -l ./data/trace_pyr.dot > /dev/null
../src/rstsp/build/rstsp.mlton -o /dev/null -t b -m 2 ../test/data/random/random.8 -l ./data/trace_bal.dot > /dev/null
for FMT in pdf eps; do
  for TYPE in apyr pyr bal; do
    dot -T${FMT} ./data/trace_${TYPE}.dot -o ./build/trace_${TYPE}.${FMT}
  done
done
