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

# FIXME: can we make this build (CML?)
#/home/madhat/opt/multiMLton-ubm/build/bin/mlton \
#    -mlb-path-map /home/madhat/opt/multiMLton-ubm/build/lib/mlb-path-map \
#    -output "${BUILD_DIR}"/rstsp.mulmlton \
#            "${SRC_DIR}"/rstsp.mlb || exit 1

mlton \
    -output "${BUILD_DIR}"/rstsp.mlton \
            "${SRC_DIR}"/rstsp.mlb || exit 1
## For mltonexception stack traces:
#      -const 'Exn.keepHistory true' \

polyc \
    -o "${BUILD_DIR}"/rstsp.poly \
       "${SRC_DIR}"/rstsp.polyc || exit 1

