#!/bin/sh
#
# $Id$
# $Author$
# $Date$
# $Revision$
#

REPORT_DIR=`realpath ${0%/*}`

cd "${REPORT_DIR}" || exit 1
rm -f -- *.output \
         cover.pdf cover.pax \
         pg_*.pdf doc_data.txt \
         *.aux *.log *.toc *.out *.lol \
         *.bcf *.bbl *.blg *.run.xml \
         *.ind *.idx *.ilg *.ing \
         *.dvi *.ps *.bm #\
         #tsp.png
#rm -f -- plots/*converted-to.png

