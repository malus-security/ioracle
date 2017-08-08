:- [all_facts,all_rules].

processes_using_symbol(S) :- findall(P,(processSignature(filePath(P),_),processSymbol(filePath(P),symbol(S))),L),sort(L,L2),maplist(writeln,L2).
