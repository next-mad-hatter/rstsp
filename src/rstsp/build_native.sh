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

echo "Building MLton executable"
mlton \
    -output "${BUILD_DIR}"/rstsp.mlton \
            ./rstsp/rstsp-mlton.mlb || exit 1

echo "Building MLton (profiled) executable"
mlton \
    -profile time \
    -output "${BUILD_DIR}"/rstsp.prof \
            ./rstsp/rstsp-mlton.mlb || exit 1

echo "Building MLton (traced) executable"
mlton \
    -const 'Exn.keepHistory true' \
    -output "${BUILD_DIR}"/rstsp.debug \
            ./rstsp/rstsp-mlton.mlb || exit 1

if type "polyc" > /dev/null; then
  echo "Building Poly/ML executable"
  polyc \
      -o "${BUILD_DIR}"/rstsp.poly \
         ./rstsp/rstsp-polyml.sml || exit 1

  echo "Building Poly/ML (threaded) executable"
  polyc \
      -o "${BUILD_DIR}"/rstsp.threaded \
         ./rstsp/rstsp-threaded.sml || exit 1
else
  echo "Poly/ML compiler not found"
fi
