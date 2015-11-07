#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`
cd "${PROJ_DIR}/plot"
mkdir -p out

./mk_csv_random.rb
./plot_num_types.gpi
./plot_random.gpi

