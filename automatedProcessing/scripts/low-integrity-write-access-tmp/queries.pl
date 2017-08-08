:- [all_facts,all_rules].

low_integrity_access(F,Op) :- findall(P,(low_integrity_process(P),process_file_access(process(P),file(F),coarseOp(Op))),L),sort(L,L2),maplist(writeln,L2).
