#!/bin/bash

#this script should run all tests and report which pass and fail

./testQueries.sh unixParsing 2> /dev/null

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
