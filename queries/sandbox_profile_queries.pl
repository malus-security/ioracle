:-
	use_module(library(regex)).

% Print `usesSandbox()` rules with files that use the entitlement dictating the use of `container` sandbox profile: `com.apple.private.security.container-required`.
containerEnt :-
	process(filePath(Path),entitlement(key("com.apple.private.security.container-required"),_)),
	write("usesSandbox(processPath(\""),write(Path),writeln("\"),profile(\"container\"),mechanism(entitlementKey(\"com.apple.private.security.container-required\")))."),
	fail.

% Print `usesSandbox()` rules with files that use a sandbox profile dictated by the `seatbelt-profiles` entitlement key.
seatbeltEnt:-
	process(filePath(Path),entitlement(key("seatbelt-profiles"),value([string(Value)]))),
	% The container2 profile does not exist and is always overridden by the container profile.
	Value \= "container2",
	write("usesSandbox(processPath(\""),write(Path),write("\"),profile(\""),write(Value),writeln("\"),mechanism(entitlementKey(\"seatbelt-profiles\")))."),
	fail.

% Print `usesSandbox()` rules with files that are given the container file in the signature.
% We can't just use entitlement facts here because not all executables have entitlements.
pathBasedProfile:-
	setof(Path, (
		processSignature(filePath(Path),_),
		Path =~ '.*/mobile/Containers/Bundle.*'
	),Pathset),
	member(X,Pathset),
	write("usesSandbox(processPath(\""),write(X),writeln("\"),profile(\"container\"),mechanism(pathBased(\".*/mobile/Containers/Bundle.*\")))."),
	fail.

% Print `usesSandbox()` rules based on strings output information: `sandbox_init` is used to map a sandbox profile to a given executable file.
% This one seems to produce duplicates. We should detect and remove them.
selfAppliedProfile:-
	setof(Path, (
		processString(filePath(Path),stringFromProgram("_sandbox_init")),
		processString(filePath(Path),stringFromProgram("_sandbox_apply_container"))
	),Out),
	member(X,Out),
	write("usesSandbox(processPath(\""),
	write(X),
	writeln("\"),profile(\"unknown\"),mechanism(selfApplied))."),
	fail.

% Get all `usesSandbox()` facts.
% Getting the profiles this way seems to have gained one more fact. Maybe there is an executable with multiple mechanisms?
getProfilesFromFacts:-
	% We should double check why this works, but it seems to give me what I expect by trying to satisfy both queries in every possible way.
	% the ; represents an OR operation, but because we are pushing to failure, maybe this is what I want according to DeMorgen's law.
	(seatbeltEnt;containerEnt;pathBasedProfile;selfAppliedProfile).
