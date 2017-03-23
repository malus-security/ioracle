#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 directoryProducedBydataExtractorForConnectedDeviceShell" 1>&2
	echo "Example: $0 iPod5_iOS812_12B440" 1>&2
	exit 1
fi

extractionDirectory="$1"
rm -rf ./temporaryFiles
mkdir ./temporaryFiles
mkdir $extractionDirectory/prologFacts > /dev/null 2>&1

#I think unpacking the extracted file system should be done in this script instead of the script for a connected device
#make the new file system owned by the current user to avoid needing sudo all the time.
#We can get the unix permissions by extracting metadata from the device, so its ok if we lose them locally.
sudo tar -xzf $extractionDirectory/fileSystem.tar.gz -C $extractionDirectory/fileSystem
sudo chown -R $USER $extractionDirectory
chmod -R 777 $extractionDirectory

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

./scriptsToAutomate/idaBatchAnalysis.sh $extractionDirectory/fileSystem ./temporaryFiles/pathsToSelfAssigners.out temporaryFiles/

./scriptsToAutomate/mapIdaScriptToTargets.sh ./temporaryFiles/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py ./temporaryFiles/ ./temporaryFiles/sandboxInit.out ./configurationFiles/sandboxInit.config

./scriptsToAutomate/mapIdaScriptToTargets.sh ./temporaryFiles/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py ./temporaryFiles/ ./temporaryFiles/sandboxInitWithParameters.out ./configurationFiles/sandboxInitWithParameters.config

./scriptsToAutomate/mapIdaScriptToTargets.sh ./temporaryFiles/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py ./temporaryFiles/ ./temporaryFiles/applyContainer.out ./configurationFiles/applyContainer.config

echo 'consolidating output of IDA analysis on sandbox self assigners with assignments based on entitlements and file paths.'
cat ./temporaryFiles/applyContainer.out temporaryFiles/sandboxInit.out temporaryFiles/sandboxInitWithParameters.out > ./temporaryFiles/selfApplySandbox.pl

cat ./temporaryFiles/selfApplySandbox.pl ./scriptsToAutomate/queries.pl > ./temporaryFiles/relevantFacts.pl
./scriptsToAutomate/runProlog.sh parseSelfAppliedProfiles > ./temporaryFiles/parsedFilteredSelfAppliers.pl
rm ./temporaryFiles/relevantFacts.pl

cat ./temporaryFiles/profileAssignmentFromEntAndPath.pl ./temporaryFiles/parsedFilteredSelfAppliers.pl > $extractionDirectory/prologFacts/processToProfileMapping.pl
