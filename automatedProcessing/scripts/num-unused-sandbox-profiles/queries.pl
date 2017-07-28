:- [all_facts,all_rules].

num_unused_sandbox_profiles :- findall(P,(profileRule(profile(P),_,_,_),not(usesSandbox(_,profile(P),_))),L),sort(L,L2),length(L2,N),writeln(N).
