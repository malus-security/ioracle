#!/bin/bash

prefix="iPhoneSE_13F69_iOS932"
echo "print_apple_exec_no_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_no_sandbox_apple_exec_files.pl
echo "print_apple_process_no_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_no_sandbox_apple_processes.pl
echo "print_apple_exec_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_apple_exec_files_sandbox.pl
echo "print_apple_process_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_apple_processes_sandbox.pl
echo "print_apple_process_permission." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_apple_processes_file_permissions.pl
