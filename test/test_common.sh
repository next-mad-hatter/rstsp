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

#"${PROJ_DIR}/src/rstsp/build_native.sh" || exit 1

mkdir -p "${LOG_DIR}" | exit 1

(time "${PROJ_DIR}"/src/rstsp/build/rstsp.poly p \
  "${DATA_DIR}"/small/* \
  "${DATA_DIR}"/misc/*) \
  > "${LOG_DIR}"/logs_poly_p 2>&1

(time "${PROJ_DIR}"/src/rstsp/build/rstsp.poly 4 \
  "${DATA_DIR}"/small/* \
  "${DATA_DIR}"/misc/*) \
  > "${LOG_DIR}"/logs_poly_4 2>&1
