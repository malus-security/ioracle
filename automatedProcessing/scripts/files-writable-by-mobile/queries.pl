:- [all_facts,all_rules].

files_writable_by_user(U) :- findall(F,(user(userName(U),_,userID(Uid),_,_,_,_),unixUserAllow(uid(Uid),coarseOp("write"),file(F))),L),sort(L,L2),maplist(writeln,L2).
