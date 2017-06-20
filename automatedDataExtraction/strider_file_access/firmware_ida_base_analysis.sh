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
echoerr 'creating list of file paths to analyze with IDA'
cp $extractionDirectory/temporaryFiles/applefilePaths.out $ida_result_directory/ida_targets.out

echoerr 'running batch ida analysis on direct file access call executables'
time ../scriptsToAutomate/idaBatchAnalysis.sh $extractionDirectory/fileSystem/ $ida_result_directory/ida_targets.out $ida_result_directory/

#the curly brackets have bundled the commands so the error output will be funneled into one file
} 2> >(tee $extractionDirectory/ida_base_analysis_error.log >&2)
