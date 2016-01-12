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
ctags -Ra

mkdir -p "${BUILD_DIR}" || exit 1

echo "***************************************"
echo
echo " Building MLton executable"
echo
mlton \
    -output "${BUILD_DIR}"/rstsp.mlton \
            ./rstsp/rstsp-mlton.mlb || exit 1

echo "***************************************"
echo
echo " Building MLton (profiled) executable"
echo
mlton \
    -profile time \
    -output "${BUILD_DIR}"/rstsp.prof \
            ./rstsp/rstsp-mlton.mlb

echo "***************************************"
echo
echo " Building MLton (allocation-profiled) executable"
echo
mlton \
    -profile alloc \
    -output "${BUILD_DIR}"/rstsp.alloc \
            ./rstsp/rstsp-mlton.mlb

echo "***************************************"
echo
echo " Building MLton (traced) executable"
echo
mlton \
    -const 'Exn.keepHistory true' \
    -output "${BUILD_DIR}"/rstsp.debug \
            ./rstsp/rstsp-mlton.mlb

if type "polyc" > /dev/null; then
  echo "***************************************"
  echo
  echo " Building Poly/ML executable"
  echo
  polyc \
      -o "${BUILD_DIR}"/rstsp.poly \
         ./rstsp/rstsp-polyml.sml || exit 1

  echo "***************************************"
  echo
  echo " Building Poly/ML (threaded) executable"
  echo
  polyc \
      -o "${BUILD_DIR}"/rstsp.threaded \
         ./experimental/rstsp-threaded.sml || exit 1
else
  echo "***************************************"
  echo
  echo "Poly/ML compiler not found"
  echo
fi
echo "***************************************"
