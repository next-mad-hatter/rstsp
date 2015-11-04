#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

SRC_DIR=`realpath ${0%/*}/`
BUILD_DIR="./build"

cd "${SRC_DIR}" || exit 1

echo "Building Poly/ML (threaded) executable"
polyc \
    -o "${BUILD_DIR}"/rstsp.threaded \
       main-threaded.sml || exit 1

echo "Building Poly/ML executable"
polyc \
    -o "${BUILD_DIR}"/rstsp.poly \
       main-polyc.sml || exit 1

echo "Building MLton executable"
mlton \
    -output "${BUILD_DIR}"/rstsp.mlton \
            rstsp-mlton.mlb || exit 1

echo "Building MLton (traced) executable"
mlton \
    -const 'Exn.keepHistory true' \
    -output "${BUILD_DIR}"/rstsp.debug \
            rstsp-mlton.mlb || exit 1

