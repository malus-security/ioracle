#!/bin/bash

# Run this script on macOS; nm requires support for MachO format.

if test $# -ne 1; then
    echo "Usage: $0 /path/to/root/filesystem/" 1>&2
    exit 1
fi

rootfs_path="$1"

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

echoerr() { echo "$@" 1>&2; }

while read line; do
    filePath="$rootfs_path$line"
    for symbol in $(nm -u -arch arm64 "$filePath"); do
        echo "externalSymbol(filePath(\"$line\"),symbol(\"$symbol\"))."
    done
done
