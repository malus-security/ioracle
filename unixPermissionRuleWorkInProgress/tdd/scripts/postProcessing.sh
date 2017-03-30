#!/bin/bash

if test $# -ne 2; then
  echo "Usage: $0 inputFile outputDirectory" 1>&2
  echo "Example: $0 input.pl outputDirectory/" 1>&2
  exit 1
fi

input=$1
outputDir=$2
plPost="../temp/postProcessing.pl"
mkdir $outputDir

cat $input postProcessingQueries.pl > $plPost
swipl --quiet -t "ignore(allFilePaths),halt(1)" --consult-file $plPost | sort | uniq > $outputDir/allFilePaths.out
./findParents.py $outputDir/allFilePaths.out > $outputDir/dirParents.pl

swipl --quiet -t "ignore(prologFriendlyPermissionFacts),halt(1)" --consult-file $plPost | sort | uniq > $outputDir/prologFriendlyPermissions.pl
