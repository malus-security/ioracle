#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1/"
rootfs_path=${rootfs_path//\/\//\/}

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

count=0
echoerr() { echo "$@" 1>&2; }
echoerr $count

for file in $(find "$rootfs_path" -type f);
do
	adjustedFilePath=${file##"$rootfs_path"}
	#sanitizedFilePath=`echo $adjustedFilePath | sed 's/"//g' | sed 's/\`//g' | sed "s/'//g" | sed 's/\\\//g'`
	#TODO I'm planning to filter out file paths with troublesome characters, but we can find a better solution later.
	sanitizedFilePath=`echo $adjustedFilePath`
	prefix=`echo file\(filePath\(\"$sanitizedFilePath\"\)`
	#it should be ok to remove troublesome characters from file type output
	fileType=`file -b -p $file | sed 's/"//g' | sed 's/\`//g' | sed "s/'//g" | sed 's/\\\//g'`
	echo $prefix,fileType\(\"$fileType\"\)\).
	count=$((count + 1))
	if ! (($count % 1000)); then
		echoerr $count
	fi
done
