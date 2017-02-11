#!/bin/bash

prefix="iPhone5S_13A452_iOS902"

# Create symlinks. This is hard-coded. Ideally it should be part of a
# config file.
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhone5S_13A452_iOS902/iPhone5S_13A452_iOS902_apple_executable_files.pl apple_executable_files.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhone5S_13A452_iOS902/iPhone5S_13A452_iOS902_apple_executable_files_entitlements.pl apple_executable_files_entitlements.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhone5S_13A452_iOS902/iPhone5S_13A452_iOS902_apple_executable_files_strings.pl apple_executable_files_strings.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhone5S_13A452_iOS902/iPhone5S_13A452_iOS902_file_metadata.pl file_metadata.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhone5S_13A452_iOS902/iPhone5S_13A452_iOS902_groups.pl groups.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhone5S_13A452_iOS902/iPhone5S_13A452_iOS902_users.pl users.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhone5S_13A452_iOS902/iPhone5S_13A452_iOS902_sandbox_profile_mappings.pl sandbox_profile_mappings.pl

echo "print_apple_exec_no_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_no_sandbox_apple_exec_files.pl
echo "print_apple_exec_sandbox." | swipl --quiet get_process_user_group_mappings.pl > "$prefix"_apple_exec_files_sandbox.pl
