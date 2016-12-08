#!/bin/bash

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

echoerr() { echo "$@" 1>&2; }

#first argument is input file consisting of list of file paths to find executables to process
filename=$1
filelines=`cat $filename`

rm "$2hashedPathToFilePathMapping.csv"

for line in $filelines ; 
do
    #./FileSystem is hardcoded and should be changed for other systems.
    #filePath="$1$line"
    filePath="/home/ladeshot/FileSystem9.0.2$line"

    hashedPath=`echo $line | md5sum | sed 's/\ .*//g'`
    #it's probably safer to separate by comma since the file paths might include spaces
    echo "$hashedPath,$line" >> $2hashedPathToFilePathMapping.csv
    #the second argument is the location to move the executables to and store the ida databases in
    cp $filePath $2$hashedPath
    idal64 -B -o$2$hashedPath.i64 $2$hashedPath
done

