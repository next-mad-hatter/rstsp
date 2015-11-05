#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

SRC_DIR=`realpath ${0%/*}/`

#DATE=`date -u +%F_%H%M`
#DATE=`date -u +%F`
DATE=`date -u +%Y%m%d`
VERSION=${VERSION:-${DATE}}
SUFFIX=src-${VERSION}
ARCHIVE=${SRC_DIR}/../../tmp/rstsp-${SUFFIX}.tar.xz

if [ -f "${ARCHIVE}" ]; then
  echo "Refusing to overwrite existing snapshot."
  exit 1
fi

cd "${SRC_DIR}" || exit 1
tar cJf "${ARCHIVE}" -h --transform 's,^,rstsp-'${SUFFIX}'/,' \
  --exclude win32 \
  --exclude build \
  --exclude pkg_\*.sh \
  --exclude polyml/\*.sh \
  --exclude polyml/\*.sml \
  * \
|| rm -- "${ARCHIVE}"
