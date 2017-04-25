#!/bin/bash

if test $# -ne 1; then
  echo "Usage: $0 inputDirectoryUsedForExtraction" 1>&2
  echo "Example: $0 iPodDataDirectory " 1>&2
  exit 1
fi

inputDirectory=$1
#this seems to be the output file for the facts and rules used in post processing for file_metadata
plPost="$inputDirectory/temporaryFiles/postProcessing.pl"

cat $inputDirectory/prologFacts/file_metadata.pl postProcessingQueries.pl > $plPost
swipl --quiet -t "ignore(allFilePaths),halt(1)" --consult-file $plPost | sort | uniq > $inputDirectory/temporaryFiles/allFilePaths.out
./findParents.py $inputDirectory/temporaryFiles/allFilePaths.out | sort | uniq > $inputDirectory/prologFacts/dirParents.pl

swipl --quiet -t "ignore(prologFriendlyPermissionFacts),halt(1)" --consult-file $plPost | sort | uniq > $inputDirectory/prologFacts/prologFriendlyPermissions.pl

mv $inputDirectory/prologFacts/unsanitized* $inputDirectory/temporaryFiles/
cat $inputDirectory/prologFacts/* | sort > $inputDirectory/godfile.pl
