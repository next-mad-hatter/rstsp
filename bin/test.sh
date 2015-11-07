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
"${TEST_DIR}"/mk_random_data.sh
"${TEST_DIR}"/mk_random_batches.rb > "${TEST_DIR}"/batch/random.json

"${TEST_DIR}"/test_common.sh
"${TEST_DIR}"/test_random.sh
