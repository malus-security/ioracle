:- [all_facts,all_rules].

:- use_module(library(regex)).

print_sandbox_profiles :- findall(P,usesSandbox(_,profile(P),_),L),sort(L,Lunique),maplist(writeln,Lunique).

num_unsandboxed_executables :- findall(F,(file(fileType(T),filePath(F)),T =~ "Mach-O",not(usesSandbox(processPath(F),_,_))),L),sort(L,L2),length(L2,N).
