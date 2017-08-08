:- [all_facts,all_rules].

high_integrity_works_in_tmp :- findall(P,(high_integrity_process(P),(process_works_in_observation(P,"/private/var/tmp");process_works_in_static_tmp(P))),L),sort(L,L2),maplist(writeln,L2).

process_works_in_observation(P,Root):-
  fileAccessObservation(process(P),sourceFile(F),_,_),stringSubPath(Root,F).

process_works_in_observation(P,Root):-
  fileAccessObservation(process(P),_,destinationFile(F),_),stringSubPath(Root,F).

process_works_in_static_tmp(P):-
  processString(filePath(P),stringFromProgram(F)), F =~ ".*/tmp/.*".
