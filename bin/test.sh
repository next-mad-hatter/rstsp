#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`
TEST_DIR="${PROJ_DIR}/test/data"

#"${PROJ_DIR}/src/rstsp/build_native.sh" || exit 1
"${PROJ_DIR}/src/rstsp/build/rstsp" 2 \
  "${TEST_DIR}"/small/* \
  "${TEST_DIR}"/misc/p01_d.txt \
  "${TEST_DIR}"/misc/lau15_dist.txt \
  "${TEST_DIR}"/misc/gr17_d.txt

"${PROJ_DIR}/src/rstsp/build/rstsp" p \
  "${TEST_DIR}"/**/*
