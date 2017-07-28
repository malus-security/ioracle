:- [all_facts,all_rules].

print_sandbox_profiles :- findall(P,usesSandbox(_,profile(P),_),L),sort(L,Lunique),maplist(writeln,Lunique).
