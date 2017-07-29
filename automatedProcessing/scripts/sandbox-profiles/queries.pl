:- [all_facts,all_rules].

sandbox_profiles :- findall(P,profileRule(profile(P),_,_,_),L),sort(L,L2),maplist(writeln,L2).
