#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1"

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

echoerr() { echo "$@" 1>&2; }

while read line; do
    #expects path to root of iOS file system as an argument.
    #todo add usage instructions as error output if argument is missing
    filePath="$rootfs_path$line"

    strings "$filePath" | grep 'apply_container' > /dev/null 2>&1
    if test $? -eq 0; then
        echo 'usesSandbox(processPath("'"$line"'"),profile("container"),mechanism("apply_container")).'
        continue    # Do not check for sandbox_init() fi apply_container() is already there.
    fi
    strings "$filePath" | grep 'sandbox_init' > /dev/null 2>&1
    if test $? -eq 0; then
        echo 'usesSandbox(processPath("'"$line"'"),profile("unknown"),mechanism("sandbox_init")).'
    fi
done

