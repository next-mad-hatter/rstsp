#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

SRC_DIR=`realpath ${0%/*}/`
BUILD_DIR="${SRC_DIR}/build"

mlton -output "${BUILD_DIR}"/rstsp \
      "${SRC_DIR}"/rstsp.mlb || exit 1
