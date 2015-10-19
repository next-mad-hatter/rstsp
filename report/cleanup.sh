#!/bin/sh
#
# $Id$
# $Author$
# $Date$
# $Revision$
#

REPORT_DIR=`realpath ${0%/*}`

cd "${REPORT_DIR}"
rm -f -- *.output *.aux *.log *.toc *.out *.lol *.dvi
cd "${REPORT_DIR}/plots"
rm -f -- *converted-to.png

