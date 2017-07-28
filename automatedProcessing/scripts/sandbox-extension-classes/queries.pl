:- [all_facts,all_rules].

sandbox_extension_classes :- findall(C,(profileRule(_,_,_,filters(L)),member(extension-class(C),L)),L2),sort(L2,L3),maplist(writeln,L3).
