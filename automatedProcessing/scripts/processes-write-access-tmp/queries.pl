:- [all_facts,all_rules].

processes_access(F,Op) :- findall(P,process_file_access(process(P),file(F),coarseOp(Op)),L),sort(L,L2),maplist(writeln,L2).
