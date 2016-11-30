#!/bin/bash

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

echoerr() { echo "$@" 1>&2; }

filename='programPaths.out'
filelines=`cat $filename`

for line in $filelines ; 
do
    #./FileSystem is hardcoded and should be changed for other systems.
    filePath="./FileSystem$line"

    identifier=`codesign --display --verbose=4 $filePath 2>&1 | grep -o '^Identifier=com.apple.*' | sed 's/Identifier=//'`

    #-z checks to see if the string is empty.
    #no identifier should indicate that the executable had no signature
    if [ ! -z "$identifier" ]; then
      echo "process(filepath(\"$line\"),identifier(\"$identifier\"))."
      #echo $line
    #else echo "process(filePath('$line'),identifier('no identifier detected'))."
    fi

done

