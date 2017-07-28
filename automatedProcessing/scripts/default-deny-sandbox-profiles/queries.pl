:- [all_facts,all_rules].

default_decision_sandbox_profiles(D) :- findall(P,profileDefault(profile(P),decision(D)),L),maplist(writeln,L).
