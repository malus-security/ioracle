#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1/"
rootfs_path=${rootfs_path//\/\//\/}

OS="`uname`"

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

echoerr() { echo "$@" 1>&2; }

while read line; do
	#expects path to root of iOS file system as an argument.
	#todo add usage instructions as error output if argument is missing
	filePath="$rootfs_path$line"
	# echo $filePath

	#this current version only outputs results for programs with com.apple as the start of their identifiers
	#identifier=`codesign --display --verbose=4 $filePath 2>&1 | grep -o '^Identifier=com.apple.*' | sed 's/Identifier=//'`
	
	# use jtool.ELF64 for linux; jtool for mac
  	if test $OS == "Linux"; then
    	identifier=`./jtool/jtool.ELF64 -arch armv7 --sig $filePath 2>&1 | grep -o '.*Identifier:[\ ]*com.apple.*' | sed 's/.*Identifier:[\ ]*//' | sed 's/\ .*//'`
  	elif test $OS == "Darwin"; then
    	identifier=`./jtool/jtool -arch armv7 --sig $filePath 2>&1 | grep -o '.*Identifier:[\ ]*com.apple.*' | sed 's/.*Identifier:[\ ]*//' | sed 's/\ .*//'`
  	fi
  
  	#-z checks to see if the string is empty.
  	#no identifier should indicate that the executable had no signature
  	if [ ! -z "$identifier" ]; then
    	echo "processSignature(filePath(\"$line\"),identifier(\"$identifier\"))."
    	#echo $line
  	#else echo "process(filePath('$line'),identifier('no identifier detected'))."
  	fi
done
