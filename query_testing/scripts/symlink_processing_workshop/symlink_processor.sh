#!/bin/bash

if test $# -ne 1; then
  echo "Usage: $0 inputDirectoryUsedForExtraction" 1>&2
  echo "Example: $0 iPod5_iOS812_12B440" 1>&2
  exit 1
fi

inputDirectory=$1
#this seems to be the output file for the facts and rules used in post processing for file_metadata
plPost="$inputDirectory/temporaryFiles/postProcessing.pl"

cat $inputDirectory/prologFacts/dynamic_facts.pl ../postProcessingQueries.pl > $plPost
swipl --quiet -t "ignore(spit_out_paths_for_dynamic),halt(1)" --consult-file $plPost | sort | uniq > $inputDirectory/temporaryFiles/dynamic_paths.out
./symlink_find_parents.py $inputDirectory/temporaryFiles/dynamic_paths.out | sort | uniq > $inputDirectory/prologFacts/dynamic_parents.pl
