#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/filetypes.pl" 1>&2
	exit 1
fi

filetype_file="$1"

cat "$filetype_file" | grep 'fileType("Mach-O ' | sed 's/^.*filePath("\([^"]*\)").*$/\1/g'
