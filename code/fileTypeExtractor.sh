#!/bin/bash

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

count=0
echoerr() { echo "$@" 1>&2; }
echoerr $count

for file in $(find . -type f);
do
	adjustedFilePath=`echo $file | sed 's/^\.//'`
	#echo $adjustedFilePath
	prefix=`echo file\(filePath\(\"$adjustedFilePath\"\)`
	fileType=`file -b -p $file | sed 's/"//g' | sed 's/\`//g' | sed "s/'//g" `
	echo $prefix,fileType\(\"$fileType\"\)\).
        count=$((count + 1))
        if ! (($count % 1000)); then
                echoerr $count
        fi

done
