#!/bin/bash

if test $# -ne 1; then
	echo "Usage: $0 directoryProducedBydataExtractorForConnectedDeviceShell" 1>&2
	echo "Example: $0 iPod5_iOS812_12B440" 1>&2
	exit 1
fi

extractionDirectory="$1"

#get file types from the file system extracted to the local system
./scriptsToAutomate/fileTypeExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/file_types.pl

#extract data about users from etc
./scriptsToAutomate/userFactExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/users.pl

#extract data about groups from etc
./scriptsToAutomate/groupFactExtractor.sh $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/groups.pl

cat $extractionDirectory/prologFacts/file_types.pl ./scriptsToAutomate/queries.pl > relevantFacts.tmp.pl
./scriptsToAutomate/runProlog.sh getProgramFacts $extractionDirectory/fileSystem > $extractionDirectory/prologFacts/machO_executables.pl
rm relevantFacts.tmp.pl
