#!/bin/sh
#
# $Id$
# $Author$
# $Date$
# $Revision$
#

SUBMISSION=report

REPORT_DIR=`realpath ${0%/*}`
trap "exit 1" INT QUIT TERM

cd "${REPORT_DIR}"
pandoc -f rst -t latex ../doc/sml-support.rst  > sml-support.tex
ctags -Ra .

../src/rstsp/build/rstsp.mlton -o /dev/null -t p ../test/data/random/random.5 -l ../plot/data/trace_pyr.dot
../src/rstsp/build/rstsp.mlton -o /dev/null -t b -m 2 ../test/data/random/random.8 -l ../plot/data/trace_bal.dot
dot -Tpdf ../plot/data/trace_pyr.dot -o ../plot/out/trace_pyr.pdf
dot -Tpdf ../plot/data/trace_bal.dot -o ../plot/out/trace_bal.pdf

#cd "${REPORT_DIR}"
wget -nc https://imgs.xkcd.com/comics/travelling_salesman_problem.png -O tsp.png

ERR="$(lualatex -shell-escape -interaction=nonstopmode -file-line-error "${SUBMISSION}".tex)"
STATUS="$?"
echo "${ERR}" | egrep ".*:[0-9]*:.*|Warning:"
if [ $STATUS -ne 0 ]; then
  exit 1
fi
biber -q "${SUBMISSION}".bcf
makeindex "${SUBMISSION}".idx
makeglossaries "${SUBMISSION}"
lualatex -shell-escape -interaction=batchmode -file-line-error "${SUBMISSION}".tex
texfot lualatex -shell-escape "${SUBMISSION}".tex

