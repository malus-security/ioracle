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

temporaryFiles=$extractionDirectory/temporaryFiles
echo "temp is $temporaryFiles"
rm -rf $temporaryFiles
mkdir $temporaryFiles
mkdir $extractionDirectory/prologFacts > /dev/null 2>&1

#I think unpacking the extracted file system should be done in this script instead of the script for a connected device
#make the new file system owned by the current user to avoid needing sudo all the time.
#We can get the unix permissions by extracting metadata from the device, so its ok if we lose them locally.

echo 'extracting archived file system'
echoerr 'extracting archived file system'
#TODO I need to put this line back in after testing
time sudo tar -xzf $extractionDirectory/fileSystem.tar.gz -C $extractionDirectory/fileSystem
sudo chown -R $USER $extractionDirectory
chmod -R 777 $extractionDirectory

echo 'getting file types'
echoerr 'getting file types'
#get file types from the file system extracted to the local system
time ./scriptsToAutomate/fileTypeExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/unsanitized_file_types.pl
time ./scriptsToAutomate/sanitizeFilePaths.py $extractionDirectory/prologFacts/unsanitized_file_types.pl > $extractionDirectory/prologFacts/file_types.pl

echo 'getting user data'
echoerr 'getting user data'
#extract data about users from etc
time ./scriptsToAutomate/userFactExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/users.pl

echo 'getting group data'
echoerr 'getting group data'
#extract data about groups from etc
time ./scriptsToAutomate/groupFactExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/groups.pl

echo 'getting file paths of Mach-O executables'
echoerr 'getting file paths of Mach-O executables'
cat $extractionDirectory/prologFacts/file_types.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
time ./scriptsToAutomate/runProlog.sh justPaths $temporaryFiles > $temporaryFiles/filePaths.out
rm $temporaryFiles/relevantFacts.pl

echo 'getting signatures of Apple-Signed Mach-O executables'
echoerr 'getting signatures of Apple-Signed Mach-O executables'
#Note that because of file path sanitization, if a mach-o executable's path was sanitized, the script won't be able to find the file.
#I don't expect this to be a problem in practice, but we can keep an eye on it to see if it every happens. It should throw an error if it does.
time ./scriptsToAutomate/signatureExtractor.sh $extractionDirectory/fileSystem < $temporaryFiles/filePaths.out > $extractionDirectory/prologFacts/apple_executable_files_signatures.pl

echo 'getting file paths for Apple-Signed Mach-O executables'
echoerr 'getting file paths for Apple-Signed Mach-O executables'
#generate a list of file paths to Apple-signed mach-o executable files
cat $extractionDirectory/prologFacts/apple_executable_files_signatures.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
time ./scriptsToAutomate/runProlog.sh justApplePaths $temporaryFiles > $temporaryFiles/applefilePaths.out
rm $temporaryFiles/relevantFacts.pl

echo 'getting entitlements for Apple-Signed Mach-O executables'
echoerr 'getting entitlements for Apple-Signed Mach-O executables'
#extract entitlements from programs listed in the input 
time ./scriptsToAutomate/entitlementExtractor.sh $extractionDirectory/fileSystem < $temporaryFiles/applefilePaths.out > $extractionDirectory/prologFacts/apple_executable_files_entitlements.pl

echo 'getting strings for Apple-Signed Mach-O executables'
echoerr 'getting strings for Apple-Signed Mach-O executables'
time ./scriptsToAutomate/stringExtractor.sh $extractionDirectory/fileSystem < $temporaryFiles/applefilePaths.out > $extractionDirectory/prologFacts/apple_executable_files_strings.pl

echo 'getting symbols for Apple-Signed Mach-O executables'
echoerr 'getting symbols for Apple-Signed Mach-O executables'
time ./scriptsToAutomate/symbolExtractor.sh $extractionDirectory/fileSystem < $temporaryFiles/applefilePaths.out > $extractionDirectory/prologFacts/apple_executable_files_symbols.pl

echo 'getting sandbox profile assignments based on entitlements and file paths'
echoerr 'getting sandbox profile assignments based on entitlements and file paths'
cat $extractionDirectory/prologFacts/apple_executable_files_signatures.pl $extractionDirectory/prologFacts/apple_executable_files_entitlements.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
time ./scriptsToAutomate/runProlog.sh getProfilesFromEntitlementsAndPaths $temporaryFiles > $temporaryFiles/profileAssignmentFromEntAndPath.pl
rm $temporaryFiles/relevantFacts.pl

echo 'getting file paths to processes that assign sandboxes to themselves.'
echoerr 'getting file paths to processes that assign sandboxes to themselves.'
cat $extractionDirectory/prologFacts/apple_executable_files_symbols.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
time ./scriptsToAutomate/runProlog.sh getSelfAssigningProcessesWithSymbols $temporaryFiles > $temporaryFiles/pathsToSelfAssigners.out
rm $temporaryFiles/relevantFacts.pl

echo 'running batch ida analysis on self assigning executables'
echoerr 'running batch ida analysis on self assigning executables'
#TODO Need to mention that I fixed an important typo here where there should have been a / after $extractionDirectory/fileSystem
time ./scriptsToAutomate/idaBatchAnalysis.sh $extractionDirectory/fileSystem/ $temporaryFiles/pathsToSelfAssigners.out $temporaryFiles/

echo 'running backtracing ida scripts on self assigning executables'
echoerr 'running backtracing ida scripts on self assigning executables'
time ./scriptsToAutomate/mapIdaScriptToTargets.sh $temporaryFiles/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py $temporaryFiles/ $temporaryFiles/sandboxInit.out ./configurationFiles/sandboxInit.config
time ./scriptsToAutomate/mapIdaScriptToTargets.sh $temporaryFiles/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py $temporaryFiles/ $temporaryFiles/sandboxInitWithParameters.out ./configurationFiles/sandboxInitWithParameters.config
time ./scriptsToAutomate/mapIdaScriptToTargets.sh $temporaryFiles/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py $temporaryFiles/ $temporaryFiles/applyContainer.out ./configurationFiles/applyContainer.config

echo 'consolidating and parsing output of IDA analysis on sandbox self assigners with assignments based on entitlements and file paths.'
echoerr 'consolidating and parsing output of IDA analysis on sandbox self assigners with assignments based on entitlements and file paths.'
cat $temporaryFiles/applyContainer.out $temporaryFiles/sandboxInit.out $temporaryFiles/sandboxInitWithParameters.out > $temporaryFiles/selfApplySandbox.pl

cat $temporaryFiles/selfApplySandbox.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
time ./scriptsToAutomate/runProlog.sh parseSelfAppliedProfiles $temporaryFiles > $temporaryFiles/parsedFilteredSelfAppliers.pl
rm $temporaryFiles/relevantFacts.pl

cat $temporaryFiles/profileAssignmentFromEntAndPath.pl $temporaryFiles/parsedFilteredSelfAppliers.pl > $extractionDirectory/prologFacts/processToProfileMapping.pl

echo 'getting vnode types. This should probably move to the connected device script later.'
cat $extractionDirectory/prologFacts/file_metadata.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
time ./scriptsToAutomate/runProlog.sh getVnodeTypes $temporaryFiles > $extractionDirectory/prologFacts/vnodeTypes.pl
rm $temporaryFiles/relevantFacts.pl

#backtracer analysis for functions known to be used in jailbreak gadgets (e.g., chown and chmod)
echo 'getting file paths to processes that use chmod or chown.'
echoerr 'getting file paths to processes that use chmod or chown.'
cat $extractionDirectory/prologFacts/apple_executable_files_symbols.pl ./scriptsToAutomate/queries.pl > $temporaryFiles/relevantFacts.pl
time ./scriptsToAutomate/runProlog.sh getDirectFileAccessCallersWithSymbols $temporaryFiles > $temporaryFiles/pathsToDirectFileAccessCallers.out
rm $temporaryFiles/relevantFacts.pl

echoerr 'running batch ida analysis on direct file access call executables'
time ./scriptsToAutomate/idaBatchAnalysis.sh $extractionDirectory/fileSystem/ $temporaryFiles/pathsToDirectFileAccessCallers.out $temporaryFiles/

time ./scriptsToAutomate/mapIdaScriptToTargets.sh $extractionDirectory/ida_base_analysis/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py  $extractionDirectory/ida_base_analysis/ $extractionDirectory/prologFacts/chown_backtrace.pl ./configurationFiles/chown.config
time ./scriptsToAutomate/mapIdaScriptToTargets.sh $extractionDirectory/ida_base_analysis/hashedPathToFilePathMapping.csv ./scriptsToAutomate/strider.py  $extractionDirectory/ida_base_analysis/ $extractionDirectory/prologFacts/chmod_backtrace.pl ./configurationFiles/chmod.config

#Now that we have a way to collect sandbox extensions, we should not need this anymore.
#It was a way to run queries assuming that no process had any sandbox extensions.
#echo "sandbox_extension( _, _) :- fail." > $extractionDirectory/prologFacts/sandboxExtensionPlaceHolders.pl

#the curly brackets have bundled the commands so the error output will be funneled into one file
} 2> >(tee $extractionDirectory/error.log >&2)

