#!/bin/bash

if test $# -gt 1; then
    echo "Usage: $0 [/path/to/store/processed/profiles]" 1>&2
    exit 1
elif test $# -eq 1; then
    rootfs_path="$1"
else
    rootfs_path="."
fi

IFS=$'\n'

while read f; do
    echo "Processing sandbox profile $f ..."
    profile_name=$(basename "$f" .sb)
    output_file="$rootfs_path"/"$profile_name".pl
    ./smartPly.py "$f" "$profile_name" > "$output_file"
done
