#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 directoryProducedBydataExtractorForConnectedDeviceShell" 1>&2
	echo "Example: $0 iPod5_iOS812_12B440" 1>&2
	exit 1
fi

extractionDirectory="$1"

if test ! -d "$extractionDirectory"; then
    echo "Extraction directory $extractionDirectory doesn't exist." 1>&2
    exit 1
fi

rm -rf ./temporaryFiles
mkdir ./temporaryFiles
mkdir $extractionDirectory/prologFacts > /dev/null 2>&1

echo 'getting file types'
##get file types from the file system extracted to the local system
./scriptsToAutomate/fileTypeExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/file_types.pl

echo 'getting user data'
#extract data about users from etc
./scriptsToAutomate/userFactExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/users.pl

echo 'getting group data'
#extract data about groups from etc
./scriptsToAutomate/groupFactExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/groups.pl

echo 'getting file paths of Mach-O executables'
cat $extractionDirectory/prologFacts/file_types.pl ./scriptsToAutomate/queries.pl > ./temporaryFiles/relevantFacts.pl
./scriptsToAutomate/runProlog.sh justPaths $extractionDirectory/fileSystem > ./temporaryFiles/filePaths.out
rm ./temporaryFiles/relevantFacts.pl

echo 'getting signatures of Apple-Signed Mach-O executables'
./scriptsToAutomate/signatureExtractor.sh $extractionDirectory/fileSystem < ./temporaryFiles/filePaths.out > $extractionDirectory/prologFacts/apple_executable_files_signatures.pl

echo 'getting file paths for Apple-Signed Mach-O executables'
#generate a list of file paths to Apple-signed mach-o executable files
cat $extractionDirectory/prologFacts/apple_executable_files_signatures.pl ./scriptsToAutomate/queries.pl > ./temporaryFiles/relevantFacts.pl
./scriptsToAutomate/runProlog.sh justApplePaths $extractionDirectory/fileSystem > ./temporaryFiles/applefilePaths.out
rm ./temporaryFiles/relevantFacts.pl

echo 'getting entitlements for Apple-Signed Mach-O executables'
#extract entitlements from programs listed in the input 
./scriptsToAutomate/entitlementExtractor.sh $extractionDirectory/fileSystem < ./temporaryFiles/applefilePaths.out > $extractionDirectory/prologFacts/apple_executable_files_entitlements.pl

echo 'getting strings for Apple-Signed Mach-O executables'
./scriptsToAutomate/stringExtractor.sh $extractionDirectory/fileSystem < ./temporaryFiles/applefilePaths.out > $extractionDirectory/prologFacts/apple_executable_files_strings.pl

echo 'getting symbols for Apple-Signed Mach-O executables'
./scriptsToAutomate/symbolExtractor.sh $extractionDirectory/fileSystem < ./temporaryFiles/applefilePaths.out > $extractionDirectory/prologFacts/apple_executable_files_symbols.pl

echo 'getting sandbox profile assignments based on entitlements and file paths'
#TODO Why am I listing the file system as an argument to runProlog.sh?
cat $extractionDirectory/prologFacts/apple_executable_files_signatures.pl $extractionDirectory/prologFacts/apple_executable_files_entitlements.pl ./scriptsToAutomate/queries.pl > ./temporaryFiles/relevantFacts.pl
./scriptsToAutomate/runProlog.sh getProfilesFromEntitlementsAndPaths > ./temporaryFiles/profileAssignmentFromEntAndPath.pl
rm ./temporaryFiles/relevantFacts.pl

echo 'getting file paths to processes that assign sandboxes to themselves.'
cat $extractionDirectory/prologFacts/apple_executable_files_symbols.pl ./scriptsToAutomate/queries.pl > ./temporaryFiles/relevantFacts.pl
./scriptsToAutomate/runProlog.sh getSelfAssigningProcessesWithSymbols > ./temporaryFiles/pathsToSelfAssigners.out
rm ./temporaryFiles/relevantFacts.pl
