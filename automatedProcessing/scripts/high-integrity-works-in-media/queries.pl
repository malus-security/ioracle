:- [all_facts,all_rules].

high_integrity_works_in_media :- findall(P,(high_integrity_process(P),(process_works_in_observation(P,"/private/var/mobile/Media");process_works_in_static_media(P))),L),sort(L,L2),maplist(writeln,L2).

process_works_in_observation(P,Root):-
  fileAccessObservation(process(P),sourceFile(F),_,_),stringSubPath(Root,F).

process_works_in_observation(P,Root):-
  fileAccessObservation(process(P),_,destinationFile(F),_),stringSubPath(Root,F).

process_works_in_static_media(P):-
  processString(filePath(P),stringFromProgram(F)), F =~ ".*/Media/.*".
