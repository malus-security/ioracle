#!/bin/bash

# changed the script to use jtool instead of nm.
# this will allow support for linux.

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
	#echo $filePath
	
	# use jtool.ELF64 for linux; jtool for mac
	if test "$OS" == "Linux"; then
		for symbol in $(./jtool/jtool.ELF64 -arch armv7 -S "$filePath" | sed 's/.*\ //g'); do
			echo "processSymbol(filePath(\"$line\"),symbol(\"$symbol\"))."
		done
	elif test "$OS" == "Darwin"; then
		for symbol in $(./jtool/jtool -arch armv7 -S "$filePath" | sed 's/.*\ //g'); do
			echo "processSymbol(filePath(\"$line\"),symbol(\"$symbol\"))."
		done
	fi
done
