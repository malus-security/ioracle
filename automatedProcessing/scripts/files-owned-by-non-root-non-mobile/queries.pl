:- [all_facts,all_rules].

files_owned_by_non_root_non_mobile :- findall(F,(not(fileOwnerUserNumber(userNumber(Uid),F),user(userName("root"),_,userId(Uid),_,_,_,_)),not(fileOwnerUserNumber(userNumber(Uid),F),user(userName("mobile"),_,userId(Uid),_,_,_,_))),L),maplist(writeln,L).
