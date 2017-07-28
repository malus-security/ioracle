:- [all_facts,all_rules].

firmware_ddi_files :- findall(F,fileSize(_,filePath(F)),L2),maplist(writeln,L2).
