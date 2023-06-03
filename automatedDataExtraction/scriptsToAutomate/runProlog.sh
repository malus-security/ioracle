#!/bin/bash

#This script takes a query name as input.
#It then loads the file relevantFacts.pl and sets the input query as a goal.
#The output should be results that satisfied the query passed in.
#The input query should be one that has been defined in queries.pl

#it seems a bit like cheating, but it's hard to write prolog that doesn't produce duplicate results, 
#so I'm just filtering out duplicates here with sort and uniq.
queryToRun=$1
temporaryFiles=$2
#swipl --quiet -t "ignore($queryToRun),halt(1)" --consult-file $temporaryFiles/relevantFacts.pl | sort | uniq
#the command above does not work, remade it as it is below.
swipl -s $temporaryFiles/relevantFacts.pl -t "ignore($queryToRun), halt(1)" | sort | uniq
