#!/bin/bash

#this script should run all tests and report which pass and fail

#TODO replace with tests that evaluate how well the post processor works.
#./testQueries.sh unixParsing 2> /dev/null

#test postProcessing script for transforming unix permissions into prolog friendly format.
input="../prolog/fakeDataForUnixParsingTests.pl"
testName="unixPermFormat"
output="../outputs/$testName/prologFriendlyPermissions.pl"
./postProcessing.sh $input ../outputs/$testName 2> /dev/null
./evaluateAnswer.sh $testName $output ../answers/"$testName".answer

input="../prolog/fakeDataForParentDirectoryTests.pl"
testName="unixParentDir"
output="../outputs/$testName/dirParents.pl"
./postProcessing.sh $input ../outputs/$testName 2> /dev/null
./evaluateAnswer.sh $testName $output ../answers/"$testName".answer

./testQueries.sh unixRunAsRoot 2> /dev/null

./testQueries.sh userRead 2> /dev/null
./testQueries.sh userWrite 2> /dev/null
./testQueries.sh userExecute 2> /dev/null

./testQueries.sh groupRead 2> /dev/null
./testQueries.sh groupWrite 2> /dev/null
./testQueries.sh groupExecute 2> /dev/null

./testQueries.sh otherRead 2> /dev/null
./testQueries.sh otherWrite 2> /dev/null
./testQueries.sh otherExecute 2> /dev/null

#./testQueries.sh dirParent 2> /dev/null
#./testQueries.sh dirParent 
