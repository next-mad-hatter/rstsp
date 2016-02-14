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


# runtime & synthetic benchmark plots

. "${PROJ_DIR}"/bin/check_ruby.sh

#./plot_num_types.gpi

./mk_csv_random.rb
./plot_random.gpi

./mk_csv_tsplib.rb
./plot_tsplib.gpi


# tsplib benchmarks -- boxplots

for FORMAT in pdf eps; do
  ./plot_tsplib.py $FORMAT
  ./plot_tsplib_times.py $FORMAT
done


# execution traces

../src/rstsp/build/rstsp.mlton -o /dev/null -t p ../test/data/random/random.5 -l ./data/trace_pyr.dot > /dev/null
../src/rstsp/build/rstsp.mlton -o /dev/null -t b -m 2 ../test/data/random/random.8 -l ./data/trace_bal.dot > /dev/null
SEPIA=#796045
for TYPE in apyr pyr bal; do
  dot -Nfontname="Candara" -Tpdf ./data/trace_${TYPE}.dot -o ./build/trace_${TYPE}.pdf
  dot -Nfontname="Candara" -Nfontcolor=${SEPIA} -Ecolor=${SEPIA} -Ncolor=${SEPIA} -Teps ./data/trace_${TYPE}.dot -o ./build/trace_${TYPE}.eps
done


# metapost illustrations

cd ./build
for file in ..//mp/*.mp; do
  mpost -s 'outputformat="eps"' -s 'outputtemplate="%j-%c.eps"' ${file}
  mpost -s 'outputformat="pdf"' -s 'outputtemplate="%j-%c.pdf"' ${file}
done


# TODO: gnuplot esp vs pdf colors

for file in {tsplib*hist*,mlton,random_val}*.pdf; do
  pdf2ps ${file}
done


