:- [all_facts,all_rules].

all_static_permission_change_name_resolution :- findall(C,static_permission_change_name_resolution(C,_,_),L),sort(L,L2),maplist(writeln,L2).
