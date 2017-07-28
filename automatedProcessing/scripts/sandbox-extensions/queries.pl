:- [all_facts,all_rules].

sandbox_extensions :- findall(C,(profileRule(_,_,_,filters(L)),member(extension(C),L)),L2),sort(L2,L3),maplist(writeln,L3).
