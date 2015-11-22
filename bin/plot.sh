#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

trap "exit 1" INT QUIT TERM

PROJ_DIR=`realpath ${0%/*}/..`
cd "${PROJ_DIR}/plot" || exit 1
mkdir -p out || exit 1

echo -n "Checking ruby version and libraries: "
$( ruby -e "if RUBY_VERSION >= \"1.9.3\" then print \"OK\" else exit(1) end" > /dev/null 2>&1 )
if [ $? -ne 0 ]; then
  echo "not found"
  exit 1
fi
echo "ok"

./plot_num_types.gpi

./mk_csv_random.rb
./plot_random.gpi

./mk_csv_tsplib.rb
./plot_tsplib.gpi
