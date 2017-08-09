:- [all_facts,all_rules].

:- use_module(library(regex)).

sandboxed_executables :- findall(F,(processSignature(filePath(F),_),usesSandbox(processPath(F),_,_)),L),sort(L,L2),maplist(writeln,L2).
