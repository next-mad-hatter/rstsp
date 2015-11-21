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

rm -rf -- "${BUILD_DIR}"/rstsp.* \
          "${BUILD_DIR}"/lib \
          "${BUILD_DIR}"/include \
          "${BUILD_DIR}"/example

