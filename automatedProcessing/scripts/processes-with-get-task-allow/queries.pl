:- [all_facts,all_rules].

processes_with_entitlement_not_in_container(E) :- findall(P,(processSignature(filePath(P),_),processEntitlement(filePath(P),entitlement(key(E),value(V))),not(usesSandbox(processPath(P),profile("container"),_)),not(V=bool("false"))),L),sort(L,L2),maplist(writeln,L2).
