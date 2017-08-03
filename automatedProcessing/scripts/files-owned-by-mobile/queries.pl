:- [all_facts,all_rules].

files_owned_by_user(U) :- findall(F,(fileOwnerUserNumber(userNumber(Uid),F),user(userName(U),_,userId(Uid),_,_,_,_)),L),maplist(writeln,L).
