:- [all_facts,all_rules].

list_users :- findall(U,user(userName(U),_,_,_,_,_,_),L),maplist(writeln,L).
