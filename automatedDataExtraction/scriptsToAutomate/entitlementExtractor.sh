#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1/"
rootfs_path=${rootfs_path//\/\//\/}

OS=$(uname)

#instead of IFS=$'\n', just read -r
while read -r line; do
  filePath="$rootfs_path$line"

	# use jtool.ELF64 for linux; use jtool for mac
	if test "$OS" == "Linux"; then
		entitlements=$(jtool/jtool.ELF64 -arch armv7 --ent "$filePath" 2>&1)
	elif test "$OS" == "Darwin"; then 
		entitlements=$(jtool/jtool -arch armv7 --ent "$filePath" 2>&1)
	fi

	entitlements=$(echo "$entitlements" | sed 's;^.*<dict>;;' | sed 's;</dict>.*$;;' | sed 's;<key>;\\\n<key>;g')
	#-z checks to see if the string is empty.
	#no identifier should indicate that the executable had no signature

	if [ -n "$entitlements" ]; then
	#echo "process(filePath('$line'),identifier('$identifier'))."
	#echo $line
	entlines=$(printf "%s\n" "$entitlements")

		for ent in $entlines; do
			keyCheck=$(echo "$ent" | grep '<key>')

			if [ -n "$keyCheck" ]; then
				entKey=$(echo "$ent" | sed 's/^.*<key>\ *//' | sed 's;\ *</key>.*;;')
				#the following code seems to be a series of sed operations with the output of the previous line flowing into the sed operations on the next line.
				entValRaw=$(echo "$ent" | sed 's;.*</key>;;' | sed 's;[\ 	]*;;g')
				entValWithStrings=$(echo "$entValRaw" | sed 's;<string>;string(";g' | sed 's;</string>;");g' |  sed 's;")string;"),string;g')
				entValWithInts=$(echo "$entValWithStrings" | sed 's;<integer>;intValue(";g' | sed 's;</integer>;");g' |  sed 's;")intValue;"),intValue;g')
				entValWithBrackets=$(echo "$entValWithInts" | sed 's;<array>;[;g' | sed 's;</array>;];g')
				#the syntax giving me trouble is <array/> which represents and empty list and can be represented in prolog as value([])
				entValWithEmptyBrackets=$(echo "$entValWithBrackets" | sed 's;<array/>;[];g')
				entValProcessBools=$(echo "$entValWithEmptyBrackets" | sed 's;<true/>;bool("true");g' | sed 's;<false/>;bool("false");g')
				entVal="$entValProcessBools"
				echo "processEntitlement(filePath(\"$line\"),entitlement(key(\"$entKey\"),value($entVal)))."
			fi

		done
  fi
done
