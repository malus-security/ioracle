apple_process_sandbox :- [process_mapping_queries, process_ownership, sandbox_profile_mappings, apple_executable_files],
   findall((Process,SandboxProfile,SandboxMechanism), mapProcessSandboxProfile(Process,SandboxProfile,SandboxMechanism), L),
   write(L),
   halt.

print_apple_process_sandbox :- [process_mapping_queries, process_ownership, sandbox_profile_mappings, apple_executable_files],
   findall((Process,SandboxProfile,SandboxMechanism), mapProcessSandboxProfile(Process,SandboxProfile,SandboxMechanism), L),
   member((P,S,M),L),
   write("mapAppleProcessSandbox(process(\""),write(P),write("\"),profile(\""),write(S),write("\"),mechanism(\""),write(M),writeln("\")."),
   fail.

exec_apple_exec_sandbox :- [process_mapping_queries, sandbox_profile_mappings, apple_executable_files],
   findall((Executable,SandboxProfile,SandboxMechanism), mapAppleExecSandboxProfile(Executable,SandboxProfile,SandboxMechanism), L),
   write(L),
   halt.

print_apple_exec_sandbox :- [process_mapping_queries, sandbox_profile_mappings, apple_executable_files],
   findall((Executable,SandboxProfile,SandboxMechanism), mapAppleExecSandboxProfile(Executable,SandboxProfile,SandboxMechanism), L),
   member((E,P,M),L),
   write("mapAppleExecSandbox(filePath(\""),write(E),write("\"),profile(\""),write(P),write("\"),mechanism(\""),write(M),writeln("\")."),
   fail.

apple_process_permission :- [process_mapping_queries, users, groups, process_ownership, apple_executable_files, file_metadata],
   findall((Process,FilePath,Permission), mapProcessPermissions(Process,FilePath,Permission), L),
   write(L),
   halt.

print_apple_process_permission :- [process_mapping_queries, users, groups, process_ownership, apple_executable_files, file_metadata],
   findall((Process,FilePath,Permission), mapProcessPermissions(Process,FilePath,Permission), L),
   member((P,F,A),L),
   write("mapAppleProcessFilePermission(process(\""),write(P),write("\"),filePath(\""),write(F),write("\"),permission(\""),write(A),writeln("\")."),
   fail.

process_file :- [process_mapping_queries, users, groups, process_ownership, apple_executable_files],
   findall((X,Y,Z), mapProcessUserGroup(X,Y,Z), L),
   write(L),
   halt.

apple_process_no_sandbox :- [process_mapping_queries, process_ownership, sandbox_profile_mappings, apple_executable_files],
   findall(Process, (processAppleNoSandboxProfile(Process)), L),
   write(L),
   halt.

print_apple_process_no_sandbox :- [process_mapping_queries, process_ownership, sandbox_profile_mappings, apple_executable_files],
   findall(Process, (processAppleNoSandboxProfile(Process)), L),
   member(P,L),
   write("noSandbox(process(\""),write(P),writeln("\"))."),
   fail.

apple_exec_no_sandbox :- [process_mapping_queries, sandbox_profile_mappings, apple_executable_files],
   findall(filePath, (appleExecNoSandboxProfile(filePath)), L),
   write(L),
   halt.

print_apple_exec_no_sandbox :- [process_mapping_queries, sandbox_profile_mappings, apple_executable_files],
   findall(Executable, (appleExecNoSandboxProfile(Executable)), L),
   member(E,L),
   write("noSandbox(filePath(\""),write(E),writeln("\"))."),
   fail.

print_process_for_user(U) :- [process_mapping_queries, users, groups, process_ownership, apple_executable_files],
   findall(Process, mapProcessUserGroup(Process, U, _), L),
   member(P, L),
   write("process(\""),write(P),writeln("\"))."),
   fail.

print_process_for_group(G) :- [process_mapping_queries, users, groups, process_ownership, apple_executable_files],
   findall(Process, mapProcessUserGroup(Process, _, G), L),
   member(P, L),
   write("process(\""),write(P),writeln("\"))."),
   fail.

print_process_for_user_group(U,G) :- [process_mapping_queries, users, groups, process_ownership, apple_executable_files],
   findall(Process, mapProcessUserGroup(Process, U, G), L),
   member(P, L),
   write("process(\""),write(P),writeln("\"))."),
   fail.

print_metadata_for_process(P) :- [process_mapping_queries, users, groups, process_ownership, apple_executable_files, sandbox_profile_mappings],
   write("process: "),writeln(P),
   (mapProcessUserGroup(P, U, G) -> (write("user: "),writeln(U),write("group: "),writeln(G)) ; (writeln("user: N/A"), writeln("group: N/A"))),
   (mapProcessSandboxProfile(P,SP,_) -> (write("sandbox_profile: "),writeln(SP)) ; (write("sandbox_profile: N/A"))),
   fail.

print_apple_process_for_sandbox_profile(SandboxProfile) :- [process_mapping_queries, process_ownership, sandbox_profile_mappings, apple_executable_files],
   findall((Process,SandboxProfile,SandboxMechanism), mapProcessSandboxProfile(Process,SandboxProfile,SandboxMechanism), L),
   member((P,_,_),L),
   write("process(\""),write(P),writeln("\"))."),
   fail.

print_apple_exec_for_sandbox_profile(SandboxProfile) :- [process_mapping_queries, sandbox_profile_mappings, apple_executable_files],
   findall((Executable,SandboxProfile,SandboxMechanism), mapAppleExecSandboxProfile(Executable,SandboxProfile,SandboxMechanism), L),
   member((E,_,_),L),
   write("filePath(\""),write(E),writeln("\"))."),
   fail.
