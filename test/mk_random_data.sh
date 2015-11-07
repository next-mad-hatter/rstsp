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

mkdir -p "${DATA_DIR}" | exit 1

for i in `seq 1 50` `seq 60 10 500` `seq 550 50 1000` `seq 1100 100 2000`; do
  FILE="${DATA_DIR}"/random.$i
  if [ ! -f "${FILE}" ]; then
    "${TEST_DIR}"/random_matrix.rb $i 1 10 > "${FILE}"
  fi
done

