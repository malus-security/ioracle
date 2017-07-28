:- [all_facts,all_rules].

num_used_sandbox_profiles :- findall(P,(profileRule(profile(P),_,_,_),usesSandbox(_,profile(P),_)),L),sort(L,L2),length(L2,N),writeln(N).
