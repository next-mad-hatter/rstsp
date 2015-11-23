#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

PROJ_DIR=`realpath ${0%/*}/..`
DATA_DIR="${PROJ_DIR}"/test/data

. "${PROJ_DIR}"/bin/check_ruby.sh

grep DIMENSION "${DATA_DIR}"/**/*.tsp "${DATA_DIR}"/random/* | \
  ruby -e 'x = STDIN.readlines.map(&:strip).map{|y| y.split(/[\s:]+/)}; puts x.map{|y| ["", y[-1], y[0]].join("\t")}.join("\n")' | \
  sort -V

