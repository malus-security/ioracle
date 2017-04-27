#!/bin/bash
#FILES=/Users/luke/oracle/allProfileSandScout/allProfileSBPL/*

#usage details
if test $# -ne 3; then
  echo "Usage: $0 directoryContainingSBPLProfiles directoryToOutputTo fileToConsolidateFactsInto" 1>&2
  echo "Example: $0 SBPLProfiles/ prologFactsForProfiles/ ./allTheProfileFacts.pl" 1>&2
  exit 1
fi

FILES=$1/*
outputDir=$2
consolidatedFacts=$3
mkdir $outputDir
for f in $FILES
do
  echo "Processing $f file..."
  fileName=`echo $f | sed 's;^.*/;;g' | sed 's;\.sb$;;'`
  ./smartPly.py $f $fileName > $outputDir/$fileName.pl
done

cat $outputDir/* > $consolidatedFacts
