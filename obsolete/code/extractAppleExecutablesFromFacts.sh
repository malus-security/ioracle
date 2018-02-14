#!/bin/bash

if test $# -ne 2; then
	echo "Usage: $0 /path/to/filetypes.pl /path/to/root_fs" 1>&2
	exit 1
fi

filetype_file="$1"
rootfs_path="$2"

cat "$filetype_file" | grep 'fileType("Mach-O ' | sed 's/^.*filePath("\([^"]*\)").*$/\1/g' | ./signatureExtractor.sh "$rootfs_path" | sed 's/^.*filePath("\([^"]*\)").*$/\1/g'
