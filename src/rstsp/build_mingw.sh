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

mkdir -p "${BUILD_DIR}" || exit 1

#
# This should host the needed win libs:
#    gmp-10.dll
#    (!empty) libgmp.a
#    include/gmp.h
# and their sources under
#    pkg
# folder.
#
LIB_DIR="${SRC_DIR}/win32"

WIN_GCC=i686-w64-mingw32-gcc
# FIXME: can we escape paths here?
MLTON_OPTS="-target-cc-opt   mingw -I${LIB_DIR}/include/ \
            -target-link-opt mingw -L${LIB_DIR} \
            -target-link-opt mingw -lgmp-10 \
            -cc-opt -I${BUILD_DIR} \
            -link-opt -L${BUILD_DIR}"
WIN_TARGET="-target i686-w64-mingw32"
WIN_BIN_EXT=.exe
WIN_LIB_EXT=.dll

mlton ${MLTON_OPTS} ${WIN_TARGET} -output "${BUILD_DIR}"/rstsp${WIN_BIN_EXT} \
      "${SRC_DIR}/rstsp-mlton.mlb" || exit 1
