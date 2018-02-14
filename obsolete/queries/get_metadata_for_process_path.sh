#!/bin/bash

if test "$#" -ne 1; then
    echo "Usage: $0 /process/path" 1>&2
    exit 1
fi

process_path="$1"

echo 'print_metadata_for_process("'"$process_path"'").' | swipl --quiet get_process_user_group_mappings.pl | grep -v '^[ \t]*$' | grep -v '^false\.$'
