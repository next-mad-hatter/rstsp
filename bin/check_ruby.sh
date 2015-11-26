#
# $File$
# $Author$
# $Date$
# $Revision$
#

$( ruby -e "if RUBY_VERSION >= \"1.9.3\" then print \"OK\" else exit(1) end" > /dev/null 2>&1 )
if [ $? -ne 0 ]; then
  echo "No suitable ruby installation found."
  exit 1
fi

