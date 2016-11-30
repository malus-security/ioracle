#!/bin/bash

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

#we needed this when using the codesign utility, but we shouldn't need it in this script.
#echoerr() { echo "$@" 1>&2; }

filename='programWithUnknownProfiles.out'
filelines=`cat $filename`

for line in $filelines ; 
do
    #FileSystem path is hardcoded and should be changed for other systems.
    filePath="/home/ladeshot/FileSystem9.0.2$line"

    #result=`strings $filePath | grep 'sandbox'`
    #result=`strings $filePath | grep 'sandbox_init'`
    result=`strings $filePath | grep 'sandbox_init\|apply_container'`
    #result=`strings $filePath | grep 'apply_container'`
    #result=`strings $filePath | grep '<key>com.apple.private.security.no-sandbox</key>'`
    #result=`grep 'sandbox_init' $filePath`
    #identifier=`codesign --display --verbose=4 $filePath 2>&1 | grep -o '^Identifier=com.apple.*' | sed 's/Identifier=//'`

    #-z checks to see if the string is empty.
    #no identifier should indicate that the executable had no signature
    if [ ! -z "$result" ]; then
      #echo "process(filepath(\"$line\"),result(\"$result\"))."
      echo $line
    fi

done

