#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1"

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

count=0
echoerr() { echo "$@" 1>&2; }
echoerr $count

for file in $(find "$rootfs_path" -type f);
do
	adjustedFilePath=${file##"$rootfs_path"}
	prefix=`echo file\(filePath\(\"$adjustedFilePath\"\)`
	fileType=`file -b -p $file | sed 's/"//g' | sed 's/\`//g' | sed "s/'//g" `
	echo $prefix,fileType\(\"$fileType\"\)\).
	count=$((count + 1))
	if ! (($count % 1000)); then
		echoerr $count
	fi
done
