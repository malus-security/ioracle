:- [all_facts,all_rules].

facts_for_sandbox_profile(P) :- findall((profile(P),A,B,C),profileRule(profile(P),A,B,C),L),maplist(writeln,L).
