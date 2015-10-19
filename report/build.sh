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

#
# This is purely for convenience.
#
cd "${REPORT_DIR}"
ctags -Ra .

#
# Two latex runs should be enough for references to settle.
#
cd "${REPORT_DIR}"
pdflatex -shell-escape "${SUBMISSION}".tex || exit 1
biber "${SUBMISSION}".bcf
pdflatex "${SUBMISSION}".tex
exec pdflatex "${SUBMISSION}".tex

