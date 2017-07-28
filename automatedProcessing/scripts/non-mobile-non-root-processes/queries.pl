:- [all_facts,all_rules].

non_mobile_non_root :- findall(F,(processOwnership(uid(UID),_,comm(F)),not(user(userName("mobile"),_,userID(UID),_,_,_,_)),not(user(userName("root"),_,userID(UID),_,_,_,_))),L),maplist(writeln,L).
