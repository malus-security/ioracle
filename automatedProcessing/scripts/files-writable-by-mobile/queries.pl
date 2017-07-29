:- [all_facts,all_rules].

files_writable_by_user(U) :- findall(F,(unixAllow(puid(U),pgid(G),coarseOp("write"),F),user(userName("mobile"),_,userId(U),_,_,_,_),groupMembership(user("mobile"),_,groupIDNumber(G))),L),maplist(writeln,L).
