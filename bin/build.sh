#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`

echo "Building native binary."
"${PROJ_DIR}/src/rstsp/build_native.sh"
echo "Building mingw binary."
"${PROJ_DIR}/src/rstsp/build_mingw.sh"
#"${PROJ_DIR}/report/build.sh"
rm -f -- "${PROJ_DIR}"/tmp/rstsp-win32_*tar.xz

