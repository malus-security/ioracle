:- [all_facts,all_rules].

processes_for_user(U) :- findall(F,(processOwnership(uid(UID),_,comm(F)),user(userName(U),_,userID(UID),_,_,_,_)),L),maplist(writeln,L).
