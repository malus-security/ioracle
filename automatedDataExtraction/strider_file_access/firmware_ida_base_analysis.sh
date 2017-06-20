#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 directoryProducedBydataExtractorForConnectedDeviceScript" 1>&2
	echo "Example: $0 iPod5_iOS812_12B440" 1>&2
	exit 1
fi

#this should allow easy output to stderr
echoerr() { echo "$@" 1>&2; }

extractionDirectory="$1"
ida_result_directory=$extractionDirectory/ida_base_analysis
mkdir $ida_result_directory

#I want to redirect any error output from the following commands to an errorLog in the extractionDirectory
{

echoerr 'getting file paths to processes that call file access functions'
#we want to widen analysis such that we process all of the executables.
#what if I use the applePaths.out file instead of searching for certain symbols?
#how many executables are there to scan in a firmware rootfs?
cat $extractionDirectory/prologFacts/apple_executable_files_symbols.pl ../scriptsToAutomate/queries.pl > ./temporary/relevantFacts.pl
time ../scriptsToAutomate/runProlog.sh getDirectFileAccessCallersWithSymbols ./temporary > ./temporary/pathsToDirectFileAccessCallers.out
rm ./temporary/relevantFacts.pl

echoerr 'running batch ida analysis on direct file access call executables'
#TODO Need to mention that I fixed an important typo here where there should have been a / after $extractionDirectory/fileSystem
time ../scriptsToAutomate/idaBatchAnalysis.sh $extractionDirectory/fileSystem/ ./temporary/pathsToDirectFileAccessCallers.out ./temporary/

#the curly brackets have bundled the commands so the error output will be funneled into one file
} 2> >(tee $extractionDirectory/ida_base_analysis_error.log >&2)
