#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`

#"${PROJ_DIR}/src/rstsp/build_mingw.sh" || exit 1
"${PROJ_DIR}/src/rstsp/pkg_mingw.sh"

