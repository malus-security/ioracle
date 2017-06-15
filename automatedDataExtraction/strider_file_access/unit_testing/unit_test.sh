#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 directoryProducedBydataExtractorForConnectedDeviceScript" 1>&2
	echo "Example: $0 iPod5_iOS812_12B440" 1>&2
	exit 1
fi

#this should allow easy output to stderr
echoerr() { echo "$@" 1>&2; }

extractionDirectory="$1"

#I want to redirect any error output from the following commands to an errorLog in the extractionDirectory
{

echoerr 'running batch ida analysis on direct file access call executables'
time ../../scriptsToAutomate/idaBatchAnalysis.sh $extractionDirectory/fileSystem/ ./temporary/pathsToDirectFileAccessCallers.out ./temporary/

echoerr 'running backtracing ida scripts on self assigning executables'
time ../../scriptsToAutomate/mapIdaScriptToTargets.sh ./temporary/hashedPathToFilePathMapping.csv ../../scriptsToAutomate/strider.py ./temporary/ ./temporary/chmod.out ../../configurationFiles/chmod.config

#the curly brackets have bundled the commands so the error output will be funneled into one file
} 2> >(tee $extractionDirectory/error.log >&2)

sleep 1
echo ''
echo 'comparing output to expected answer:'
diff ./temporary/chmod.out ./test_answer/chmod.out
