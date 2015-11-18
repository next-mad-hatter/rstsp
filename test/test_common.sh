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
DATA_DIR="${TEST_DIR}"/data
LOG_DIR="${TEST_DIR}"/log

mkdir -p "${LOG_DIR}" | exit 1

(time "${PROJ_DIR}"/src/rstsp/build/rstsp.mlton -t p -i 100 -j 10 -r none \
  "${DATA_DIR}"/small/* \
  "${DATA_DIR}"/misc/* ) \
  > "${LOG_DIR}"/common_p 2>&1

(time "${PROJ_DIR}"/src/rstsp/build/rstsp.mlton -t b -m 3 -i 100 -j 10 -r none \
  "${DATA_DIR}"/small/* \
  "${DATA_DIR}"/misc/* ) \
  > "${LOG_DIR}"/common_b 2>&1

