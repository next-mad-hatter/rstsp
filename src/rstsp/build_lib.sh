#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

SRC_DIR=`realpath ${0%/*}/`
BUILD_DIR=${SRC_DIR}/build
LIB_DIR=${BUILD_DIR}/lib
INC_DIR=${BUILD_DIR}/include
mkdir -p "${INC_DIR}" || exit 1
mkdir -p "${LIB_DIR}" || exit 1

#
# This should host the needed win libs:
#    gmp-10.dll
#    (!empty) libgmp.a
#    include/gmp.h
# and their sources under
#    pkg
# folder.
#
WIN_DIR=${SRC_DIR}/win32

LIN_GCC=gcc
WIN_GCC=i686-w64-mingw32-gcc
# FIXME: can we escape paths here?
MLTON_OPTS="-target-cc-opt   mingw -I${WIN_DIR}/include/ \
            -target-link-opt mingw -L${WIN_DIR} \
            -target-link-opt mingw -lgmp-10 \
            -cc-opt -I${INC_DIR} \
            -link-opt -L${LIB_DIR}"
WIN_TARGET="-target i686-w64-mingw32"

echo "***************************************"
echo
echo -n " Building librstsp.so    "
mlton ${MLTON_OPTS} \
      -format library -libname rstsp -export-header "${INC_DIR}"/rstsp.h \
      -output "${LIB_DIR}"/librstsp.so \
      "${SRC_DIR}"/librstsp/librstsp.mlb || exit 1
echo "done."

cd "${LIB_DIR}"
if ! mlton ${WIN_TARGET} > /dev/null; then
  echo " No crosscompiler found."
else
  echo -n " Building rstsp.dll      "
  mlton ${MLTON_OPTS} ${WIN_TARGET} \
        -format library -libname rstsp \
        -output "${LIB_DIR}"/rstsp.dll \
        "${SRC_DIR}"/librstsp/librstsp.mlb || exit 1
  echo "done."
fi

echo -n " Building test           "
${LIN_GCC} \
      -I"${INC_DIR}" -L"${LIB_DIR}" \
      -o "${BUILD_DIR}"/test \
      -lrstsp \
      "${SRC_DIR}"/librstsp/test.c || exit 1
echo "done."
echo
echo " Running test:"
env LD_LIBRARY_PATH="${LIB_DIR}" "${BUILD_DIR}"/test || exit 1
echo
echo "***************************************"
