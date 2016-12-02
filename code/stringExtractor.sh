#!/bin/bash

#the find command also has a printf option and provides much of the same data as stat
IFS=$'\n'

echoerr() { echo "$@" 1>&2; }

filename='appleProgramList.out'
filelines=`cat $filename`

for line in $filelines ; 
do
    #./FileSystem is hardcoded and should be changed for other systems.
    #this should really be a parameter passed in as a command line argument...
    filePath="/home/ladeshot/FileSystem9.0.2$line"

    #echo "about to process $line"

    #I think this will only work if I set the minimum string length to a reasonably high number.
    #otherwise, I get a bunch of junk...
    #I wonder if IDA has a smarter way to remove strings that are not of interest.
    #for now I am limiting the results to strings of 7 or more ascii characters.
    #the strings must have at least three consecutive numbers or letters.
    #the strings must not contain backslashes or double quotes
    thisSetOfStrings=`strings -n 7 $filePath | grep '[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]' | grep -v '"' | grep -v '\\\\'`

    #echo "about to iterate through strings"
    for stringEntry in $thisSetOfStrings ;
    do 
        #echo "about to output a prolog fact"
        echo "process(filePath(\"$line\"),stringFromProgram(\"$stringEntry\"))."
    done


done

