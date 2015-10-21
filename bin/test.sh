#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`

"${PROJ_DIR}/src/rstsp/build_native.sh" || exit 1
"${PROJ_DIR}/src/rstsp/build/rstsp" test/data/*

