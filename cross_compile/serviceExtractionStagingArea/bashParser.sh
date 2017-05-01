#!/bin/bash

for files in plists/*.plist
do
	fileName="`pwd`/"$files
	python2.7 parser.py $fileName
done
