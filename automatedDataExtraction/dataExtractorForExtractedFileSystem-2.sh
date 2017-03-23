#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 directoryProducedBydataExtractorForConnectedDeviceShell" 1>&2
	echo "Example: $0 iPod5_iOS812_12B440" 1>&2
	exit 1
fi

extractionDirectory="$1"

# Test existence of files for IDA-centric scripts.

if test ! -d "$extractionDirectory"; then
    echo "Extraction directory $extractionDirectory doesn't exist." 1>&2
    exit 1
fi

if test ! -d "$extractionDirectory"/fileSystem; then
    echo "File system folder $extractionDirectory/fileSystem doesn't exist." 1>&2
    exit 1
fi

if test ! -f temporaryFiles/pathsToSelfAssigners.out; then
    echo "File temporaryFiles/pathsToSelfAssigners.out doesn't exist." 1>&2
    exit 1
fi

mkdir $extractionDirectory/prologFacts > /dev/null 2>&1

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
