#!/bin/sh
#
# $Id$
# $Author$
# $Date$
# $Revision$
#

PLOT_DIR=`realpath ${0%/*}`

cd "${PLOT_DIR}" || exit 1
rm -f -- data/out/*pdf \
         data/mlton_*.csv \
         data/poly_*.csv

