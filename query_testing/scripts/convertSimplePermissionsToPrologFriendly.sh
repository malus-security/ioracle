#!/bin/bash

if test $# -ne 1; then
        echo "Usage: $0 inputFile" 1>&2
        echo "Example: $0 input.pl" 1>&2
        exit 1
fi

input=$1

cat $input ../prolog/unixAllowRules.pl > ../temp/prologFriendlyFormat.pl
swipl --quiet -t "ignore(prologFriendlyPermissionFacts),halt(1)" --consult-file ../temp/prologFriendlyFormat.pl | sort | uniq

