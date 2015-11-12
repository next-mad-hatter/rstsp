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

(time "${PROJ_DIR}"/src/rstsp/build/rstsp.mlton -t p -i 30 \
  "${DATA_DIR}"/small/* \
  "${DATA_DIR}"/misc/* 2>&1 ; sleep 1) \
  > "${LOG_DIR}"/common_p 2>&1

(time "${PROJ_DIR}"/src/rstsp/build/rstsp.mlton -t b -m 4 -i 30 \
  "${DATA_DIR}"/small/* \
  "${DATA_DIR}"/misc/* ; sleep 1) \
  > "${LOG_DIR}"/common_m4 2>&1

