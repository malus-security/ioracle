:-
	use_module(library(regex)).

process(P) :-
	processSignature(filePath(P),_),
	(processOwnership(_,_,comm(P)), fail; (P \~ '\\.dylib$', P \~ '/(.*)\\.siriUIBundle|appex|bundle|framework|xpc|axbundle|gtdtplugin|axuiservice|assistantBundle|plugin|pdev|driver|migrator|ppp|brailledriver|brailletable|servicebundle|speechbundle|syncBundle|lockbundle|vsplugin|mediastream|addresshandler/\1$', P \~ '^/private/var/containers/')).

path(F) :-
	file(filepath(F),_).

print_process :- [apple_executable_files, process_ownership],
	findall(P,process(P),L),
	member(X,L),
	write("process(\""),write(X),writeln("\")."),
	fail.

% This ends up in an "ERROR: Out of global stack" message.
print_path :- [file_metadata],
	findall(P,path(P),L),
	member(X,L),
	write("path(\""),write(X),writeln("\")."),
	fail.
