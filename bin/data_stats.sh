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
  ruby -e 'x = STDIN.readlines.map(&:strip).map{|y| y.split(/[\s:]+/)}
           puts x.map{|y|
             open(y[0]){|f| f.find{|l| l =~ /EDGE_WEIGHT_TYPE[\s:]+(\S+)/}}
             wt = $1
             open(y[0]){|f| f.find{|l| l =~ /EDGE_WEIGHT_FORMAT[\s:]+(\S+)/}}
             wf = $1
             [y[-1], wt || "", wf || "-", y[0]]
           }.sort_by{|r| r[0].to_i}
            .map{|r| ["",r[0].rjust(8), r[1].ljust(10), r[2].rjust(16), r[3]].join("\t")}
            .join("\n")'

