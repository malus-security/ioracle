#!/bin/bash

#this script should run all tests and report which pass and fail

#test postProcessing script for transforming unix permissions into prolog friendly format.
input="../prolog/fakeDataForUnixParsingTests"
testName="unixPermFormat"
output="../outputs/$testName/prologFriendlyPermissions.pl"
./postProcessing.sh $input 2> /dev/null
cp $input/prologFacts/prologFriendlyPermissions.pl $output
./evaluateAnswer.sh $testName $output ../answers/"$testName".answer

#test postProcessing script for representing parent child relationships for directories and their contents as prolog facts
input="../prolog/fakeDataForParentDirectoryTests"
testName="unixParentDir"
output="../outputs/$testName/dirParents.pl"
#I made big changes to the post processor, so this isn't going to work anymore...
./postProcessing.sh $input 2> /dev/null
cp $input/prologFacts/dirParents.pl $output
./evaluateAnswer.sh $testName $output ../answers/"$testName".answer

#root seems to have access to all files regardless of their unix permissions
./testQueries.sh unixRunAsRoot 2> /dev/null

#the following tests evaluate basic unix permissions for various bit configurations, users, and groups
#e.g., what files does a given process have write access to?
#user, group, and other represent when the process is the user owner, a member of the owning group (or matching effective group), or other respectively.
./testQueries.sh userRead 2> /dev/null
./testQueries.sh userWrite 2> /dev/null
./testQueries.sh userExecute 2> /dev/null

./testQueries.sh groupRead 2> /dev/null
./testQueries.sh groupWrite 2> /dev/null
./testQueries.sh groupExecute 2> /dev/null

./testQueries.sh otherRead 2> /dev/null
./testQueries.sh otherWrite 2> /dev/null
./testQueries.sh otherExecute 2> /dev/null

#which directories are accessible to a process based on their execute permissions?
#my understanding is that the current directory and all parents must be executable for the subject to access files in the directory
./testQueries.sh dirExecute 2> /dev/null

#sandbox based tests
./testQueries.sh processAttributes 2> /dev/null
./testQueries.sh noFilters 2> /dev/null
./testQueries.sh entitlementFilters 2> /dev/null
./testQueries.sh literalFilters 2> /dev/null
./testQueries.sh regexFilters 2> /dev/null
./testQueries.sh subpathFilters 2> /dev/null
./testQueries.sh prefixFilters 2> /dev/null
./testQueries.sh wildSubject 2> /dev/null
./testQueries.sh vnodeFilters 2> /dev/null
./testQueries.sh requireNot 2> /dev/null
./testQueries.sh machLiteral 2> /dev/null
./testQueries.sh machRegex 2> /dev/null
# My understanding of extensions has changed, and this test now seems invalid. It will be replaced with a better one.
#./testQueries.sh extensionFilters 2> /dev/null
./testQueries.sh sandboxExtensions_files 2> /dev/null
./testQueries.sh sandboxExtensions_mach 2> /dev/null



