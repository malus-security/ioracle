#!/bin/bash

if test $# -ne 1; then
    echo "Usage: $0 username" 2>&1
    exit 1
fi

user="$1"

echo 'print_process_for_user("'"$user"'").' | swipl --quiet get_process_user_group_mappings.pl | grep -v '^[ \t]*$' | grep -v '^false\.$'
