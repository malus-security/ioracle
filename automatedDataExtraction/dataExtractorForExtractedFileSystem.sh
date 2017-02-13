#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 directoryProducedBydataExtractorForConnectedDeviceShell" 1>&2
	echo "Example: $0 iPod5_iOS812_12B440" 1>&2
	exit 1
fi

extractionDirectory="$1"
rm -rf ./temporaryFiles
mkdir ./temporaryFiles

#get file types from the file system extracted to the local system
./scriptsToAutomate/fileTypeExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/file_types.pl

#extract data about users from etc
./scriptsToAutomate/userFactExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/users.pl

#extract data about groups from etc
./scriptsToAutomate/groupFactExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/groups.pl

cat $extractionDirectory/prologFacts/file_types.pl ./scriptsToAutomate/queries.pl > ./temporaryFiles/relevantFacts.pl
./scriptsToAutomate/runProlog.sh justPaths $extractionDirectory/fileSystem > ./temporaryFiles/filePaths.out
rm ./temporaryFiles/relevantFacts.pl

./scriptsToAutomate/signatureExtractor.sh $extractionDirectory/fileSystem < ./temporaryFiles/filePaths.out > $extractionDirectory/prologFacts/apple_executable_files_signatures.pl

#generate a list of file paths to Apple-signed mach-o executable files
cat $extractionDirectory/prologFacts/apple_executable_files_signatures.pl ./scriptsToAutomate/queries.pl > ./temporaryFiles/relevantFacts.pl
./scriptsToAutomate/runProlog.sh justApplePaths $extractionDirectory/fileSystem > ./temporaryFiles/applefilePaths.out
rm ./temporaryFiles/relevantFacts.pl

#extract entitlements from programs listed in the input 
./scriptsToAutomate/entitlementExtractor.sh $extractionDirectory/fileSystem < ./temporaryFiles/applefilePaths.out > $extractionDirectory/prologFacts/apple_executable_files_entitlements.pl
