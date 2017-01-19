#!/bin/bash

#TODO replace this hardcoded solution with something passes as an argument.
FILES=/home/ladeshot/pocketsand/ply/allProfileSBPL/*
for f in $FILES
do
  echo "Processing $f file..."
  fileName=`echo $f | sed 's;^.*/;;g' | sed 's;\.sb$;;'`
  ./smartPly.py $f $fileName > ./allProfileFacts/$fileName.pl
  # take action on each file. $f store current file name
  #cat $f
done
