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

print_low_integrity_processes :- [basic_rules, process_ownership, sandbox_profile_mappings, apple_executable_files],
	findall(P, lowIntegrity(P), L),
	member(X,L),
	write("lowIntegrity(\""),write(X),writeln("\")."),
	fail.

print_high_integrity_processes :- [basic_rules, process_ownership, sandbox_profile_mappings, apple_executable_files],
	findall(P, highIntegrity(P), L),
	member(X,L),
	write("highIntegrity(\""),write(X),writeln("\")."),
	fail.
