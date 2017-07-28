:- [all_facts,all_rules].

list_used_sandbox_profiles :- findall(P,(profileRule(profile(P),_,_,_),usesSandbox(_,profile(P),_)),L),sort(L,L2),maplist(writeln,L2).
