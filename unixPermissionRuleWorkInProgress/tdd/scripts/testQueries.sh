#!/bin/bash

#This script takes a query name as input.
#It then loads the file queries.pl and sets the input query as a goal.
#The output should be results that satisfied the query passed in.
#The input query should be one that has been defined in queries.pl

#it seems a bit like cheating, but it's hard to write prolog that doesn't produce duplicate results, 
#so I'm just filtering out duplicates here with sort and uniq.

if test $# -ne 3; then
        echo "Usage: $0 queryFile queryToTest testToApply" 1>&2
        echo "Example: $0 unixAllowRules.pl prologFriendlyPermissionFacts unixParsing" 1>&2
        exit 1
fi

queryFile=../prolog/$1
queryToTest=$2
testName=$3
input=../inputs/"$3".pl
output=../outputs/"$3".out
answer=../answers/"$3".answer
temp=../temp/"$3".pl
rm ../temp/*

cat $queryFile $input > $temp
#cat $temp
swipl --quiet -t "ignore($queryToTest),halt(1)" --consult-file $temp | sort | uniq > $output
resultSize=`diff $output $answer | wc -l`
if [ $resultSize = "0" ]; then
  echo $testName "test passed"
else
  printf "%s test failed\n\n" "$testName"
  diff $output $answer
fi

