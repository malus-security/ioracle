#!/bin/bash

if test $# -ne 1; then
  echo "Usage: $0 inputDirectoryUsedForExtraction" 1>&2
  echo "Example: $0 iPod5_iOS812_12B440" 1>&2
  exit 1
fi

inputDirectory=$1
#this seems to be the output file for the facts and rules used in post processing for file_metadata
plPost="$inputDirectory/temporaryFiles/postProcessing.pl"

#we want to process the parents of file paths discovered in dynamic analysis too, so we need to include the results of the symlink resolution script
#cat $inputDirectory/prologFacts/file_metadata.pl postProcessingQueries.pl > $plPost
cat $inputDirectory/prologFacts/symlinks_resolved_backtrace_results_and_dynamic_data.pl $inputDirectory/prologFacts/file_metadata.pl postProcessingQueries.pl > $plPost
swipl --quiet -t "ignore(allMetaDataFilePaths),halt(1)" --consult-file $plPost | sort | uniq > $inputDirectory/temporaryFiles/allFilePaths.out
swipl --quiet -t "ignore(allParameterFilePaths),halt(1)" --consult-file $plPost | sort | uniq >> $inputDirectory/temporaryFiles/allFilePaths.out
swipl --quiet -t "ignore(allAccessedFilePaths),halt(1)" --consult-file $plPost | sort | uniq >> $inputDirectory/temporaryFiles/allFilePaths.out
swipl --quiet -t "ignore(allExtensionFilePaths),halt(1)" --consult-file $plPost | sort | uniq >> $inputDirectory/temporaryFiles/allFilePaths.out
cat $inputDirectory/temporaryFiles/allFilePaths.out | sort | uniq > $inputDirectory/temporaryFiles/uniquePaths.temp
mv $inputDirectory/temporaryFiles/uniquePaths.temp $inputDirectory/temporaryFiles/allFilePaths.out
./findParents.py $inputDirectory/temporaryFiles/allFilePaths.out | sort | uniq > $inputDirectory/prologFacts/dirParents.pl

swipl --quiet -t "ignore(prologFriendlyPermissionFacts),halt(1)" --consult-file $plPost | sort | uniq > $inputDirectory/prologFacts/prologFriendlyPermissions.pl

mv $inputDirectory/prologFacts/unsanitized* $inputDirectory/temporaryFiles/
cat $inputDirectory/prologFacts/* | sort | uniq > $inputDirectory/all_facts.pl
