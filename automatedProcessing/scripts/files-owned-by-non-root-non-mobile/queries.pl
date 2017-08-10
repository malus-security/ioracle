:- [all_facts,all_rules].

files_owned_by_non_root_non_mobile :- findall(F,(fileOwnerUserNumber(userNumber(Uid),F),not(user(userName("root"),_,userID(Uid),_,_,_,_)),not(user(userName("mobile"),_,userID(Uid),_,_,_,_))),L),maplist(writeln,L).
