:-
	use_module(library(regex)).

process(P) :-
	processSignature(filePath(P),_),
	(processOwnership(_,_,comm(P)), fail; (P \~ '\\.dylib$', P \~ '/(.*)\\.siriUIBundle|appex|bundle|framework|xpc|axbundle|gtdtplugin|axuiservice|assistantBundle|plugin|pdev|driver|migrator|ppp|brailledriver|brailletable|servicebundle|speechbundle|syncBundle|lockbundle|vsplugin|mediastream|addresshandler/\1$', P \~ '^/private/var/containers/')).

path(F) :-
	file(filepath(F),_).

print_processes :- [apple_executable_files, process_ownership],
	findall(P,process(P),L),
	member(X,L),
	write("process(\""),write(X),writeln("\")."),
	fail.

% This ends up in an "ERROR: Out of global stack" message.
print_paths :- [file_metadata],
	findall(P,path(P),L),
	member(X,L),
	write("path(\""),write(X),writeln("\")."),
	fail.

%I'm planning to assume any sandboxed process is of low integrity
lowIntegrity(Process):-
	process(Process),
	usesSandbox(processPath(Process),_,_).

%We want to say that a high integrity process is an unsandboxed process
highIntegrity(Process):-
	%the \+ should represent negation.
	%prolog will try to find a matching fact through exhaustive search.
	%if it can't, then it will return true.
	%we should only use negation for small fact collections like this one because of the exhaustive search.
	%otherwise we would need to create a fact collection listing unsandboxed processes.
	process(Process),
	\+ usesSandbox(processPath(Process),_,_).

print_low_integrity_processes :- [process_ownership, sandbox_profile_mappings, apple_executable_files],
	findall(P, lowIntegrity(P), L),
	member(X,L),
	write("lowIntegrity(\""),write(X),writeln("\")."),
	fail.

print_high_integrity_processes :- [process_ownership, sandbox_profile_mappings, apple_executable_files],
	findall(P, highIntegrity(P), L),
	member(X,L),
	write("highIntegrity(\""),write(X),writeln("\")."),
	fail.

sandboxAssignment(P, S) :-
	process(P),
	(usesSandbox(processPath(P),profile(Sandbox),_) -> S = Sandbox ; S = "none").

print_sandboxAssignments :- [apple_executable_files, process_ownership, sandbox_profile_mappings],
	findall((P,S),sandboxAssignment(P,S),L),
	member((X,Y),L),
	write("sandboxAssignment(process(\""),write(X),write("\"),profile(\""),write(Y),writeln("\")."),
	fail.
