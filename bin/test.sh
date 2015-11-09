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

echo "Creating test data"
"${TEST_DIR}"/mk_random_data.sh
"${TEST_DIR}"/mk_batches_random_low.rb > "${TEST_DIR}"/batch/random_low.json
"${TEST_DIR}"/mk_batches_random_med.rb > "${TEST_DIR}"/batch/random_med.json
"${TEST_DIR}"/mk_batches_random_hi.rb > "${TEST_DIR}"/batch/random_hi.json

echo "Running batch: random/low"
"${TEST_DIR}"/run_batch.rb "${TEST_DIR}"/log/random_low.json "${TEST_DIR}"/batch/random_low.json
echo "Running batch: random/hi"
"${TEST_DIR}"/run_batch.rb "${TEST_DIR}"/log/random_hi.json "${TEST_DIR}"/batch/random_hi.json
echo "Running batch: common"
"${TEST_DIR}"/test_common.sh

