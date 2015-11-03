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

echo "Building Poly/ML executable"
polyc \
    -o "${BUILD_DIR}"/rstsp.poly \
       "${SRC_DIR}"/main-polyc.sml || exit 1

echo "Building MLton executable"
mlton \
    -output "${BUILD_DIR}"/rstsp.mlton \
            "${SRC_DIR}"/rstsp-mlton.mlb || exit 1
## For mltonexception stack traces:
#      -const 'Exn.keepHistory true' \

echo "Building MLton (CML) executable"
mlton \
    -output "${BUILD_DIR}"/rstsp.cmlmlton \
            "${SRC_DIR}"/rstsp-cmlmlton.mlb || exit 1

echo "Building multiMLton/Pacml executable"
/home/madhat/opt/multiMLton/trunk/build/bin/mlton \
    -mlb-path-map /home/madhat/opt/multiMLton/trunk/build/lib/mlb-path-map \
    -output "${BUILD_DIR}"/rstsp.multimlton \
            "${SRC_DIR}"/rstsp-multimlton.mlb || exit 1

