#!/bin/bash

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

echoerr() { echo "$@" 1>&2; }

filename="$1"

while read line; do
    #expects path to root of iOS file system as an argument.
    #todo add usage instructions as error output if argument is missing
    filePath="$1$line"
    #filePath="./FileSystem$line"

    #this current version only outputs results for programs with com.apple as the start of their identifiers
    identifier=`codesign --display --verbose=4 $filePath 2>&1 | grep -o '^Identifier=com.apple.*' | sed 's/Identifier=//'`

    #-z checks to see if the string is empty.
    #no identifier should indicate that the executable had no signature
    if [ ! -z "$identifier" ]; then
      echo "processSignature(filePath(\"$line\"),identifier(\"$identifier\"))."
      #echo $line
    #else echo "process(filePath('$line'),identifier('no identifier detected'))."
    fi
done
