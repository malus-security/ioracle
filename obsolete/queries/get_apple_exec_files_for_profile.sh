#!/bin/bash

if test $# -ne 1; then
    echo "Usage: $0 sandbox_profile" 2>&1
    exit 1
fi

sandbox_profile="$1"

echo 'print_apple_exec_for_sandbox_profile("'"$sandbox_profile"'").' | swipl --quiet get_process_user_group_mappings.pl | grep -v '^[ \t]*$' | grep -v '^false\.$'
