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

cd "${REPORT_DIR}" || exit 1
pandoc -f rst -t latex ../doc/sml-support.rst  > sml-support.tex
ctags -Ra .

#cd "${REPORT_DIR}"
wget -nc https://imgs.xkcd.com/comics/travelling_salesman_problem.png -O tsp.png

## REPORT
ERR="$(lualatex -shell-escape -interaction=nonstopmode -file-line-error "${SUBMISSION}".tex)"
STATUS="$?"
echo "${ERR}" | egrep ".*:[0-9]*:.*|Warning:"
if [ $STATUS -ne 0 ]; then
  exit 1
fi
biber -q "${SUBMISSION}".bcf
# xindy is broken on my machine
makeindex "${SUBMISSION}".idx
makeglossaries "${SUBMISSION}"
lualatex -shell-escape -interaction=batchmode -file-line-error "${SUBMISSION}".tex
texfot lualatex -shell-escape "${SUBMISSION}".tex

## SLIDES
#ERR="$(latex -shell-escape -interaction=nonstopmode -file-line-error slides.tex)"
#STATUS="$?"
#echo "${ERR}" | egrep ".*:[0-9]*:.*|Warning:"
#if [ $STATUS -ne 0 ]; then
#  exit 1
#fi
#latex -shell-escape -interaction=batchmode -file-line-error slides.tex
#texfot latex -shell-escape slides.tex
#dvips slides.dvi
#ps2pdf slides.ps
