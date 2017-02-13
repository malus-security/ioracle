#!/bin/bash

#This script takes a query name as input.
#It then loads the file relevantFacts.pl and sets the input query as a goal.
#The output should be results that satisfied the query passed in.
#The input query should be one that has been defined in queries.pl

#it seems a bit like cheating, but it's hard to write prolog that doesn't produce duplicate results, 
#so I'm just filtering out duplicates here with sort and uniq.
swipl --quiet -t "ignore($1),halt(1)" --consult-file ./temporaryFiles/relevantFacts.pl | sort | uniq
