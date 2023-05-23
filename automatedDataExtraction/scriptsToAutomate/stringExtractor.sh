#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 /path/to/root/filesystem/" 1>&2
	exit 1
fi

rootfs_path="$1/"
rootfs_path=${rootfs_path//\/\//\/}

#instead of IFS=$'\n', just read -r
while read -r line; do
  #./FileSystem is hardcoded and should be changed for other systems.
  #this should really be a parameter passed in as a command line argument...
  filePath="$rootfs_path$line"

  #echo "about to process $line"

  #I think this will only work if I set the minimum string length to a reasonably high number.
  #otherwise, I get a bunch of junk...
  #I wonder if IDA has a smarter way to remove strings that are not of interest.
  #for now I am limiting the results to strings of 7 or more ascii characters.
  #the strings must have at least three consecutive numbers or letters.
  #the strings must not contain backslashes or double quotes
  #thisSetOfStrings=$(strings -n 7 $filePath | grep '[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]' | grep -v '"' | grep -v '\\\\')

  #echo "about to iterate through strings"
  #I'm not sure why, but the while loop works, and the for loop causes the script to fail.
  #It may have something to do with memory requirements and how for loops work in bash.
  #for stringEntry in $thisSetOfStrings; do
  strings -n 7 "$filePath" | grep '[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]' | grep -v '"' | grep -v '\\\\' | while read -r stringEntry; do
    #echo "about to output a prolog fact"
    echo "processString(filePath(\"$line\"),stringFromProgram(\"$stringEntry\"))."
  done
done
