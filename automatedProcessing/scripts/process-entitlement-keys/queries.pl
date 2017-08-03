:- [all_facts,all_rules].

process_entitlement_keys :- findall(K,processEntitlement(_,entitlement(key(K),_)),L),sort(L,L2),maplist(writeln,L2).
