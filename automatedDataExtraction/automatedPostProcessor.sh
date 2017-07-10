#!/bin/bash

if test $# -ne 3; then
  echo "Usage: $0 directory_for_iOS_version_analysis directory_for_sandbox_extensions directory_for_other_dynamic_data" 1>&2
  echo "Example: $0 iPod5_iOS812_12B440 ipod_6_ios_10.1.1 ipod_5_ios_8.1.2" 1>&2
  exit 1
fi

firmware_directory="$1"
extension_directory="$2"
other_dynamic_directory="$3"

#resolve symbolic links to their absolute paths
cat $firmware_directory/prologFacts/file_metadata.pl | grep '^fileSymLink(' | grep -v '^fileSymLink(symLinkObject(""),filePath' > $firmware_directory/temporaryFiles/symlinks.pl

cat $firmware_directory/prologFacts/chmod_backtrace.pl  $firmware_directory/prologFacts/chown_backtrace.pl > $firmware_directory/temporaryFiles/backtracer_results.pl
mv $firmware_directory/prologFacts/chmod_backtrace.pl $firmware_directory/temporaryFiles/chmod_backtrace.pl
mv $firmware_directory/prologFacts/chown_backtrace.pl $firmware_directory/temporaryFiles/chown_backtrace.pl

./scriptsToAutomate/map_sym_to_absolute.py $firmware_directory/temporaryFiles/backtracer_results.pl $other_dynamic_directory/prologFacts/dynamicFileAccess.pl $other_dynamic_directory/prologFacts/processOwnershipFacts.pl $extension_directory/prologFacts/sandboxExtensions.pl $firmware_directory/temporaryFiles/symlinks.pl > $firmware_directory/prologFacts/symlinks_resolved_backtrace_results_and_dynamic_data.pl

#get directory parents, generate prolog friendly permissions, and consolidate, sort, and deduplicate facts
current_dir=`pwd`
cd ../query_testing/scripts
./postProcessing.sh $firmware_directory
cd $current_dir
