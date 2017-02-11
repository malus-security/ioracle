#!/bin/bash

prefix="iPhoneSE_13F69_iOS932"

# Create symlinks. This is hard-coded. Ideally it should be part of a
# config file.
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhoneSE_13F69_iOS932/iPhoneSE_13F69_iOS932_executable_files.pl executable_files.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhoneSE_13F69_iOS932/iPhoneSE_13F69_iOS932_apple_executable_files.pl apple_executable_files.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhoneSE_13F69_iOS932/iPhoneSE_13F69_iOS932_apple_executable_files_entitlements.pl apple_executable_files_entitlements.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhoneSE_13F69_iOS932/iPhoneSE_13F69_iOS932_apple_executable_files_strings.pl apple_executable_files_strings.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhoneSE_13F69_iOS932/iPhoneSE_13F69_iOS932_file_metadata.pl file_metadata.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhoneSE_13F69_iOS932/iPhoneSE_13F69_iOS932_filetypes.pl filetypes.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhoneSE_13F69_iOS932/iPhoneSE_13F69_iOS932_groups.pl groups.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhoneSE_13F69_iOS932/iPhoneSE_13F69_iOS932_users.pl users.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhoneSE_13F69_iOS932/iPhoneSE_13F69_iOS932_sandbox_profile_mappings.pl sandbox_profile_mappings.pl
ln -sfn /mnt/sdb3/razvan/ios-security/iOracle-prolog-facts/iPhoneSE_13F69_iOS932/iPhoneSE_13F69_iOS932_process_ownership.pl process_ownership.pl

echo "print_apple_exec_no_sandbox." | swipl --quiet get_process_user_group_mappings.pl | grep -v '^[ \t]*$' | grep -v '^false\.$' > "$prefix"_no_sandbox_apple_exec_files.pl
echo "print_apple_process_no_sandbox." | swipl --quiet get_process_user_group_mappings.pl | grep -v '^[ \t]*$' | grep -v '^false\.$' > "$prefix"_no_sandbox_apple_processes.pl
echo "print_apple_exec_sandbox." | swipl --quiet get_process_user_group_mappings.pl | grep -v '^[ \t]*$' | grep -v '^false\.$' > "$prefix"_apple_exec_files_sandbox.pl
echo "print_apple_process_sandbox." | swipl --quiet get_process_user_group_mappings.pl | grep -v '^[ \t]*$' | grep -v '^false\.$' > "$prefix"_apple_processes_sandbox.pl
echo 'print_process_for_user("mobile").' | swipl --quiet get_process_user_group_mappings.pl | grep -v '^[ \t]*$' | grep -v '^false\.$' > "$prefix"_mobile_processes.pl
echo 'print_process_for_user("root").' | swipl --quiet get_process_user_group_mappings.pl | grep -v '^[ \t]*$' | grep -v '^false\.$' > "$prefix"_root_processes.pl

> "$prefix"_apple_processes_file_permissions.pl
num_lines=$(wc -l < "$prefix"_file_metadata.pl)
echo "num_lines: $num_lines"
for i in $(seq 0 20000 "$num_lines"); do
    sed -n "$(($i+1)),$(($i+20000))p" < "$prefix"_file_metadata.pl > file_metadata.pl
    echo "print_apple_process_permission." | swipl --quiet get_process_user_group_mappings.pl >> "$prefix"_apple_processes_file_permissions.pl
done
