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

echo "Building Poly/ML (threaded) executable"
polyc \
    -o "${BUILD_DIR}"/rstsp.threaded \
       "${SRC_DIR}"/main-threaded.sml || exit 1

echo "Building Poly/ML executable"
polyc \
    -o "${BUILD_DIR}"/rstsp.poly \
       "${SRC_DIR}"/main-polyc.sml || exit 1

echo "Building MLton executable"
mlton \
    -output "${BUILD_DIR}"/rstsp.mlton \
            "${SRC_DIR}"/rstsp-mlton.mlb || exit 1

echo "Building MLton (traced) executable"
mlton \
    -const 'Exn.keepHistory true' \
    -output "${BUILD_DIR}"/rstsp.debug \
            "${SRC_DIR}"/rstsp-mlton.mlb || exit 1
