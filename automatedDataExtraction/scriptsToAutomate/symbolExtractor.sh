#!/bin/bash

# changed the script to use jtool instead of nm.
# this will allow support for linux.

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
    #echo $filePath
    for symbol in $(./jtool/jtool.ELF64 -S "$filePath" | sed 's/.*\ //g'); do
        echo "processSymbol(filePath(\"$line\"),symbol(\"$symbol\"))."
    done
done
