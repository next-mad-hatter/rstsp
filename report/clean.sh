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
         *.aux *.log *.toc *.out *.lol \
         *.bcf *.bbl *.blg *.run.xml \
         *.dvi
#rm -f -- plots/*converted-to.png

