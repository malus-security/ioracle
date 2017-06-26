#!/bin/bash

#this script compares the output of a query to the expected answer for a given test.
#If the test passes, then the output is "PASSED: $testName"
#If the test fails, then the output is "FAILED: $testName" followed by a diff of the respective output and answer files.

if test $# -ne 3; then
  echo "Usage: $0 testName output answer" 1>&2
  echo "Example: $0 test1 outputs/test1.out answers/test1.answer/" 1>&2
  exit 1
fi

testName=$1
output=$2
answer=$3
sortedAnswer=../temp/"$testName".sorted.answer
rm ../temp/*

answerSize=`cat $answer | wc -l`
cat $answer | sort | uniq > $sortedAnswer
resultSize=`diff $output $sortedAnswer | wc -l`
if [ $answerSize = "0" ]; then
  echo "FAILED: $testName"
  echo "Nothing in answer file." | sed 's/^/\t/'
elif [ $resultSize = "0" ]; then
  echo "PASSED: $testName"
else
  echo "FAILED: $testName"
  diff $output $sortedAnswer | sed 's/^/\t/'
fi
