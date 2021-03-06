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

#DATE=`date -u +%F_%H%M`
#DATE=`date -u +%F`
DATE=`date -u +%Y%m%d`
VERSION=${VERSION:-${DATE}}
SUFFIX=win32-${VERSION}
ARCHIVE=${BUILD_DIR}/../../../tmp/rstsp-${SUFFIX}.tar.xz

if [ -f "${ARCHIVE}" ]; then
  echo "Refusing to overwrite existing snapshot."
  exit 1
fi

cd "${BUILD_DIR}" || exit 1
tar cJf "${ARCHIVE}" -h --transform 's,^,rstsp-'${SUFFIX}'/,' \
  rstsp.exe include/rstsp.h \
  -C lib rstsp.dll rstsp.def \
  -C ../../librstsp test.c \
  -C ../win32 README_GMP.txt libgmp-10.dll \
  pkg/gmp-5.0.1-1-mingw32-src.tar.lzma \
  pkg/LGPL.txt \
|| rm -- "${ARCHIVE}"

