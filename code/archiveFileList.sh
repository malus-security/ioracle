#!/bin/bash

# Receive file list at standard input. If input_file.txt contains files, use
# ./zipFileList.sh a.tar < input_file.txt
# Output file is the first parameter.

if test $# -ne 1; then
    echo "Usage: $0 <ouput-file>.tar" 2>&1
    exit 1
fi

IFS=$'\n'

while read f; do
    tar -rf "$1" "$f"
done
