:- [all_facts,all_rules].

list_unused_sandbox_profiles :- findall(P,(profileRule(profile(P),_,_,_),not(usesSandbox(_,profile(P),_))),L),sort(L,L2),maplist(writeln,L2).
