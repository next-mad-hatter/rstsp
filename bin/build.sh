#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`

"${PROJ_DIR}/src/rstsp/build_native.sh"
"${PROJ_DIR}/src/rstsp/build_mingw.sh"
"${PROJ_DIR}/src/rstsp/build_lib.sh"
#"${PROJ_DIR}/report/build.sh"

