#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`
TEST_DIR="${PROJ_DIR}/test"

#"${PROJ_DIR}/src/rstsp/build_native.sh" || exit 1
"${TEST_DIR}/test.sh
