#!/bin/bash

prefix="iPhone5S_13A452_iOS902"

echo "print_apple_exec_no_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_no_sandbox_apple_exec_files.pl
echo "print_apple_exec_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_apple_exec_files_sandbox.pl
