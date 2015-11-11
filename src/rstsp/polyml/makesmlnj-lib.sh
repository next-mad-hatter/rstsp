#!/bin/sh

# Path to the MLton library source.
# Used by this script to find the *.mlb files.
MLBSRC=/usr/lib64/mlton/sml

# Path to the patch smlnj-lib source.
# Used as the default root value in the generated code.
LIBSRC=/usr/lib64/mlton/sml

LIBS='Util/smlnj-lib.mlb,util
      Controls/controls-lib.mlb,controls
      HashCons/hash-cons-lib.mlb,hashcons
      HTML/html-lib.mlb,html
      INet/inet-lib.mlb,inet
      PP/pp-lib.mlb,pp
      Reactive/reactive-lib.mlb,reactive
      RegExp/regexp-lib.mlb,regexp
      Unix/unix-lib.mlb,unix'

echo 'structure Word31 = Word;'
echo 'structure Int32 = Int;'
echo 'structure WordVector = Word8Vector'
echo 'structure Unsafe = struct
          structure CharVector = CharVector
          structure Vector = Vector
          structure Array = Array
          structure CharArray = struct
            open CharArray

            fun create n = array (n, #"0")
          end
          structure Word8Array = Word8Array
          structure Word8Vector = Word8Vector
      end;'

echo "local"
echo "val root = \"$LIBSRC\""
echo

for l in ${LIBS}
do
    FILE=`expr "$l" : '\(.*\),'`
    VARN=`expr "$l" : '.*,\(.*\)'`
    echo "val $VARN = ["
    cat $MLBSRC/smlnj-lib/$FILE | sed 's/ *(\*.*\*) *//'  \
                                | egrep '\.(sml|sig)$'    \
                                | sed 's/^ *\(.*\)/"\1",/'
    echo '""]'
    echo
done

echo 'fun dol ("",_) =()'
echo '  | dol (dn,l) =List.app(fn "" => ()
                                | s => use(root^"/smlnj-lib/"^dn^"/"^s)) l'

echo "in"
echo "val _ = List.app dol ["
for l in ${LIBS}
do
    DIRN=`expr "$l" : '\([^/]*\)'`
    VARN=`expr "$l" : '.*,\(.*\)'`
    echo "(\"$DIRN\", $VARN),"
done
echo '("", [])]'
echo "end;"

