#!/bin/bash

prefix="iPhoneSE_13F69_iOS932"
echo "print_apple_exec_no_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_no_sandbox_apple_exec_files.pl
echo "print_apple_process_no_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_no_sandbox_apple_processes.pl
echo "print_apple_exec_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_apple_exec_files_sandbox.pl
echo "print_apple_process_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_apple_processes_sandbox.pl

> "$prefix"_apple_processes_file_permissions.pl
num_lines=$(wc -l < "$prefix"_file_metadata.pl)
echo "num_lines: $num_lines"
for i in $(seq 0 20000 "$num_lines"); do
    sed -n "$(($i+1)),$(($i+20000))p" < "$prefix"_file_metadata.pl > file_metadata.pl
    echo "print_apple_process_permission." | swipl --quiet get_process_user_group_mappings.pl >> "$prefix"_apple_processes_file_permissions.pl
done
