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

for BATCH in steady low med hi; do
  echo "Creating batch: random/${BATCH}"
  "${TEST_DIR}"/mk_batches_random_${BATCH}.rb > "${TEST_DIR}"/batch/random_${BATCH}.json
  echo "Running batch: random/${BATCH}"
  "${TEST_DIR}"/run_batch.rb "${TEST_DIR}"/log/random_${BATCH}.json "${TEST_DIR}"/batch/random_${BATCH}.json
done

"${TEST_DIR}"/test_common.sh

