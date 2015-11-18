#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`

"${PROJ_DIR}/src/rstsp/clean.sh"
"${PROJ_DIR}/plot/clean.sh"
"${PROJ_DIR}/report/clean.sh"

rm -f -- "${PROJ_DIR}"/tmp/rstsp-win32_*tar.xz

