#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`
TEST_DIR="${PROJ_DIR}"/test
DATA_DIR="${TEST_DIR}"/data/random
LOG_DIR="${TEST_DIR}"/log

#"${PROJ_DIR}/src/rstsp/build_native.sh" || exit 1

mkdir -p "${DATA_DIR}" | exit 1
mkdir -p "${LOG_DIR}" | exit 1
rm -f -- "${LOG_DIR}"/*random*

for i in {1..20}; do
  "${TEST_DIR}"/random_matrix.rb $i 1 10 > "${DATA_DIR}"/random.$i
  (time "${PROJ_DIR}"/src/rstsp/build/rstsp.poly -v -t b "${DATA_DIR}"/random.$i )\
    > "${LOG_DIR}"/log_random_$i 2>&1
done

grep -iE 'real|types|store' "${LOG_DIR}"/log_random_* >> "${LOG_DIR}"/log_random

