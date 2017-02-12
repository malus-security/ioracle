:- 
  use_module(library(regex)).

containerEnt:-
  process(filePath(Path),entitlement(key("com.apple.private.security.container-required"),_)),
  write("usesSandbox(processPath(\""),write(Path),writeln("\"),profile(\"container\"),mechanism(entitlementKey(\"com.apple.private.security.container-required\")))."),
  fail.

seatbeltEnt:-
  process(filePath(Path),entitlement(key("seatbelt-profiles"),value([string(Value)]))),
  %the container2 profile does not exist and is always overridden by the container profile
  Value \= "container2",
  write("usesSandbox(processPath(\""),write(Path),write("\"),profile(\""),write(Value),writeln("\"),mechanism(entitlementKey(\"seatbelt-profiles\")))."),
  fail.

pathBasedProfile:-
  setof(Path,
    (
      processSignature(filePath(Path),_),
      Path =~ '.*/mobile/Containers/Bundle.*'
    ),Pathset),
  member(X,Pathset),
  write("usesSandbox(processPath(\""),write(X),writeln("\"),profile(\"container\"),mechanism(pathBased(\".*/mobile/Containers/Bundle.*\")))."),
  fail.


%getting the profiles this way seems to have gained one more fact. Maybe there is an executable with multiple mechanisms?
getProfilesFromEntitlementsAndPaths:-
  [systemEntitlementFacts],
  [appleProgramSignatures],
  %I should double check why this works, but it seems to give me what I expect by trying to satisfy both queries in every possible way.
  %the ; represents an OR operation, but because we are pushing to failure, maybe this is what I want according to DeMorgen's law.
  (seatbeltEnt; containerEnt; pathBasedProfile).

getSelfAssigningProcesses:-
  [stringsFromPrograms],
  setof(Path,
  (
      processString(filePath(Path),stringFromProgram("_sandbox_init"))
    ;
      processString(filePath(Path),stringFromProgram("_sandbox_apply_container"))
  ),Out),
  member(X,Out),
  writeln(X),
  fail.

getSelfAssigningProcessesWithExternalSymbols:-
  [externalSymbols],
  setof(Path,
  (
      externalSymbol(filePath(Path),symbol("_sandbox_init"))
    ;
      externalSymbol(filePath(Path),symbol("_sandbox_apply_container"))
  ),Out),
  member(X,Out),
  writeln(X),
  fail.



%ignore any profile with a parenthesis in it
%consider running a bash script to remove duplicate rules.
%I should write a bash script that automates the entire process of figuring out which sandboxes are selfApplied, finding the self-applied profiles used, and deduplicating.
parseSelfAppliedProfiles:-
  [selfApplySandbox],
  functionCalled(filePath(X),_,parameter(Z)),
  %we got at least one sandbox initialization that used a self defined profile.
  %this is worth mentioning in the paper, but it needs to be removed from these results.
  %manual analysis suggests that this self defined profile is not normally used.
  Z =~ '^[^()]+$',
  write("usesSandbox(processPath(\""),write(X),
  write("\"),profile(\""),write(Z),
  writeln("\"),mechanism(selfApplied))."),
  fail.
