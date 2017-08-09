:- [all_facts,all_rules].

executables_using_sandbox_profile(P) :- findall(F,(processSignature(filePath(F),_),usesSandbox(processPath(F),profile(P),_)),L),sort(L,L2),maplist(writeln,L2).
