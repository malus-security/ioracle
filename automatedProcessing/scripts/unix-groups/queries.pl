:- [all_facts,all_rules].

list_groups :- findall(G,group(groupName(G),_,_,_),L),maplist(writeln,L).
