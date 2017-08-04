:- [all_facts,all_rules].

executables_using_sandbox_profile(P) :- findall(F,(file(fileType(T),filePath(F)),T =~ "Mach-O",usesSandbox(processPath(F),profile(P),_)),L),sort(L,L2),maplist(writeln,L2).
executables_using_sandbox_profile2(P) :- file(fileType(T),filePath(F)),T =~ "Mach-O",usesSandbox(processPath(F),profile(P),_),writeln(F),fail.
