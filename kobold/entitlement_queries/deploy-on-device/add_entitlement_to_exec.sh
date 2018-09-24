#!/bin/bash

if test $# -ne 3; then
    echo "Usage: $0 <in_exec_file> <ent_file> <out_exec_file>" 1>&2
    exit 1
fi

in_exec_file="$1"
ent_file="$2"
out_exec_file="$3"

if test ! -f "$in_exec_file"; then
    echo "Error: First argument ($in_exec_file) is not a file." 1>&2
    exit 1
fi

if test ! -f "$ent_file"; then
    echo "Error: Second argument ($ent_file) is not a file." 1>&2
    exit 1
fi

JTOOL="/Users/razvan/bin/jtool"

$JTOOL -arch arm64 -e arch "$in_exec_file"
JDEBUG=1 $JTOOL -arch arm64 --sign --ent "$ent_file" --inplace "$in_exec_file".arch_arm64
mv "$in_exec_file".arch_arm64 "$out_exec_file"
