#!/bin/bash
FILES=/Users/luke/oracle/allProfileSandScout/allProfileSBPL/*
for f in $FILES
do
  echo "Processing $f file..."
  fileName=`echo $f | sed 's;^.*/;;g' | sed 's;\.sb$;;'`
  ./smartPly.py $f $fileName > ./allProfileFacts/$fileName.pl
  # take action on each file. $f store current file name
  #cat $f
done
