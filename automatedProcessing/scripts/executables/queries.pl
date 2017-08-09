:- [all_facts,all_rules].

:- use_module(library(regex)).

executables :- findall(F,processSignature(filePath(F),_),L),sort(L,L2),maplist(writeln,L2).
