:- [all_facts,all_rules].

:- use_module(library(regex)).

unsandboxed_executables :- findall(F,(file(fileType(T),filePath(F)),T =~ "Mach-O",not(usesSandbox(processPath(F),_,_))),L),sort(L,L2),maplist(writeln,L2).
