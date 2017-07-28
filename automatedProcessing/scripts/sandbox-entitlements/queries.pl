:- [all_facts,all_rules].

sandbox_entitlements :- findall(E,(profileRule(_,_,_,filters(L)),member(require-not(require-entitlement(E)),L)),L2),findall(E,(profileRule(_,_,_,filters(L)),member(require-entitlement(E,_),L)),L3),append(L2,L3,L4),sort(L4,L5),maplist(writeln,L5).
