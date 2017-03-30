#!/bin/bash

#This script takes a query name as input.
#It then loads the file queries.pl and sets the input query as a goal.
#The output should be results that satisfied the query passed in.
#The input query should be one that has been defined in queries.pl

#it seems a bit like cheating, but it's hard to write prolog that doesn't produce duplicate results, 
#so I'm just filtering out duplicates here with sort and uniq.

if test $# -ne 1; then
        echo "Usage: $0 queryToTest" 1>&2
        echo "Example: $0 userRead " 1>&2
        exit 1
fi

queryFile=tests.pl
queryToTest=$1
testName=$1
output=../outputs/"$1".out
answer=../answers/"$1".answer
sortedAnswer=../temp/"$1".answer
rm ../temp/*

swipl --quiet -t "ignore($queryToTest),halt(1)" --consult-file $queryFile | sort | uniq > $output

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
