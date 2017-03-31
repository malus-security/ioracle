#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1/"
rootfs_path=${rootfs_path//\/\//\/}

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

echoerr() { echo "$@" 1>&2; }

while read line; do
    filePath="$rootfs_path$line"

    entitlements=`jtool/jtool.ELF64 --ent $filePath 2>&1`
    entitlements=`echo $entitlements | sed 's;^.*<dict>;;' | sed 's;</dict>.*$;;' | sed 's;<key>;\\\n<key>;g'`
    #-z checks to see if the string is empty.
    #no identifier should indicate that the executable had no signature

    if [ ! -z "$entitlements" ]; then
      #echo "process(filePath('$line'),identifier('$identifier'))."
      #echo $line
      entlines=`printf $entitlements`
      for ent in $entlines;
      do
	keyCheck=`echo $ent | grep '<key>'`
	if [ ! -z "$keyCheck" ]; then
	  entKey=`echo $ent | sed 's/^.*<key>\ *//' | sed 's;\ *</key>.*;;'`
	  entValRaw=`echo $ent | sed 's;.*</key>;;' | sed 's;[\ 	]*;;g'`
	  entValWithStrings=`echo $entValRaw | sed 's;<string>;string(";g' | sed 's;</string>;");g' |  sed 's;")string;"),string;g'`
	  entValWithInts=`echo $entValWithStrings | sed 's;<integer>;intValue(";g' | sed 's;</integer>;");g' |  sed 's;")intValue;"),intValue;g'`
	  entValWithBrackets=`echo $entValWithInts | sed 's;<array>;[;g' | sed 's;</array>;];g'`
	  entValProcessBools=`echo $entValWithBrackets | sed 's;<true/>;bool("true");g' | sed 's;<false/>;bool("false");g'` 
	  entVal=`echo $entValProcessBools`
	  echo "process(filePath(\"$line\"),entitlement(key(\"$entKey\"),value($entVal)))."
	fi
      done
    fi
done
