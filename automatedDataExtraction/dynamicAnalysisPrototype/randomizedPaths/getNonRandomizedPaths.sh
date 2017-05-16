#!/bin/bash

if test $# -ne 2; then
	echo "Usage: $0 dynamicFileAccess1.pl dynamicFileAccess2.pl" 1>&2
	exit 1
fi

firstPrologFileAccess="$1"
secondPrologFileAccess="$2"
firstFiles="firstFiles"
secondFiles="secondFiles"

python getPathsFromDynamicFileAccess.py $firstPrologFileAccess > $firstFiles
python getPathsFromDynamicFileAccess.py $secondPrologFileAccess > $secondFiles

# get common files
#python compareFiles.py $firstFiles $secondFiles | sort | uniq

# create prolog facts with nonRandomizedPath
python compareFiles.py $firstFiles $secondFiles | sort | uniq | sed 's/.*/nonRandomizedPath("&")./' > nonRandomizedFiles.pl

rm $firstFiles $secondFiles
