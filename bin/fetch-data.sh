#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`
TEST_DIR="${PROJ_DIR}/test"
TMP_DIR="${PROJ_DIR}/tmp"

mkdir -p "${TEST_DIR}" || exit 1
mkdir -p "${TMP_DIR}" || exit 1


#
# TSPLIB data
#

DATA_DIR="${TEST_DIR}"/data/tsplib
mkdir -p "${DATA_DIR}" || exit 1

wget --continue \
      'http://www.iwr.uni-heidelberg.de/groups/comopt/software/TSPLIB95/tsp/ALL_tsp.tar.gz' \
      -O "${TMP_DIR}"/tsplib.tar.gz &&
  tar xzf "${TMP_DIR}"/tsplib.tar.gz -C "${DATA_DIR}" &&
  chmod -x "${DATA_DIR}"/* &&
  gunzip -f "${DATA_DIR}"/*.gz

[ -f "${DATA_DIR}"/SOLUTIONS.txt ] || lynx -dump -nolist \
  'http://comopt.ifi.uni-heidelberg.de/software/TSPLIB95/STSP.html' \
  > "${DATA_DIR}"/SOLUTIONS.txt


#
# DIMACS TSP Challenge data
#

DATA_DIR="${TEST_DIR}"/data/dimacs
mkdir -p "${DATA_DIR}" || exit 1

wget --continue \
      'http://dimacs.rutgers.edu/Challenges/TSP/big.tar' \
      -O "${TMP_DIR}"/dimacs-big.tar &&
  tar xf "${TMP_DIR}"/dimacs-big.tar -C "${DATA_DIR}" &&
  chmod -x "${DATA_DIR}"/* &&
  gunzip -f "${DATA_DIR}"/*.gz

wget --continue \
      'http://dimacs.rutgers.edu/Challenges/TSP/sample.tar' \
      -O "${TMP_DIR}"/dimacs-rand.tar &&
  tar xf "${TMP_DIR}"/dimacs-rand.tar -C "${DATA_DIR}" \
      --transform 's/$/.tsp/'

wget --continue \
      'http://dimacs.rutgers.edu/Challenges/TSP/bounds' \
      -O ${DATA_DIR}/BOUNDS.txt

#
# VLSI data
#

DATA_DIR="${TEST_DIR}"/data/vlsi
mkdir -p "${DATA_DIR}" || exit 1

wget --continue \
      'http://www.math.uwaterloo.ca/tsp/vlsi/vlsi_tsp.tgz' \
      -O "${TMP_DIR}"/vlsi.tar.gz &&
  tar xzf "${TMP_DIR}"/vlsi.tar.gz -C "${DATA_DIR}"/..

[ -f "${DATA_DIR}"/SUMMARY.txt ] || lynx -dump -nolist \
    'http://www.math.uwaterloo.ca/tsp/vlsi/summary.html' \
    > "${DATA_DIR}"/SUMMARY.txt

#
# National data
#

DATA_DIR="${TEST_DIR}"/data/world
mkdir -p "${DATA_DIR}" || exit 1

[ -f "${DATA_DIR}"/SUMMARY.txt ] || lynx -dump -nolist \
  'http://www.math.uwaterloo.ca/tsp/world/summary.html' \
  > "${DATA_DIR}"/SUMMARY.txt

