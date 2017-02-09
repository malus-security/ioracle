process_profile :- [process_mapping_queries, iPhoneSE_13F69_iOS932_process_ownership, iPhoneSE_13F69_iOS932_sandbox_profile_mappings, iPhoneSE_13F69_iOS932_apple_executable_files],
   findall((Process,SandboxProfile,SandboxMechanism), mapProcessSandboxProfile(Process,SandboxProfile,SandboxMechanism), L),
   write(L),
   halt.

process_permission :- [process_mapping_queries, iPhoneSE_13F69_iOS932_users, iPhoneSE_13F69_iOS932_groups, iPhoneSE_13F69_iOS932_process_ownership, iPhoneSE_13F69_iOS932_apple_executable_files, file_metadata],
   findall((Process,FilePath,Permission), mapProcessPermissions(Process,FilePath,Permission), L),
   write(L),
   halt.

process_file :- [process_mapping_queries, iPhoneSE_13F69_iOS932_users, iPhoneSE_13F69_iOS932_groups, iPhoneSE_13F69_iOS932_process_ownership, iPhoneSE_13F69_iOS932_apple_executable_files],
   findall((X,Y,Z), mapProcessUserGroup(X,Y,Z), L),
   write(L),
   halt.
