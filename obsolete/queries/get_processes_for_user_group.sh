#!/bin/bash

if test $# -ne 2; then
    echo "Usage: $0 username group" 2>&1
    exit 1
fi

user="$1"
group="$2"

echo 'print_process_for_user_group("'"$user"'","'"$group"'").' | swipl --quiet get_process_user_group_mappings.pl | grep -v '^[ \t]*$' | grep -v '^false\.$'
