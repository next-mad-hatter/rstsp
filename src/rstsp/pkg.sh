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

DATE=`date -u +%F_%H%M`
#DATE=`date -u +%Y%m%d`
#DATE=`date -u +%F`
ARCHIVE=${BUILD_DIR}/../../../tmp/rstsp-win32_${DATE}.tar.xz

if [ -f "${ARCHIVE}" ]; then
  echo "Refusing to overwrite existing snapshot."
  exit 1
fi

cd "${BUILD_DIR}" || exit 1
tar cJf "${ARCHIVE}" -h --transform 's,^,rstsp/,' \
  rstsp.exe \
  -C ../win32 \
  README_GMP \
  libgmp-10.dll \
  -C ./pkg \
  gmp-5.0.1-1-mingw32-src.tar.lzma \
|| rm -- "${ARCHIVE}"
