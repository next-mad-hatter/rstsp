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

. "${PROJ_DIR}"/bin/check_ruby.sh
$( ruby -e "require \"powerbar\"" > /dev/null 2>&1 )
if [ $? -ne 0 ]; then
  echo "ruby/powerbar not found"
  exit 1
fi

echo "***************************************"
echo
echo " Creating random test data"
echo
"${TEST_DIR}"/mk_random_data.sh

for BATCH in steady len low med hi; do
  echo " Batch: random/${BATCH}"
  "${TEST_DIR}"/mk_batches_random_${BATCH}.rb > "${TEST_DIR}"/batch/random_${BATCH}.json
  "${TEST_DIR}"/run_batch.rb "${TEST_DIR}"/log/random_${BATCH}.json "${TEST_DIR}"/batch/random_${BATCH}.json
  echo
done

#for BATCH in small med add; do
for BATCH in small med; do
  echo " Batch: tsplib/${BATCH}"
  "${TEST_DIR}"/mk_batches_tsplib_${BATCH}.rb > "${TEST_DIR}"/batch/tsplib_${BATCH}.json
  "${TEST_DIR}"/run_batch.rb "${TEST_DIR}"/log/tsplib_${BATCH}.json "${TEST_DIR}"/batch/tsplib_${BATCH}.json
  echo
done
echo "***************************************"
