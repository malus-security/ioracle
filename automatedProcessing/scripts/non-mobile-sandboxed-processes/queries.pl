:- [all_facts,all_rules].

sandboxed_processes_not_for_user(U) :- findall(F,(processOwnership(uid(UID),_,comm(F)),usesSandbox(processPath(F),_,_),not(user(userName(U),_,userID(UID),_,_,_,_))),L),maplist(writeln,L).
