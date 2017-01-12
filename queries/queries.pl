:- 
  use_module(library(regex)).
  %[typeFacts].
  %[systemEntitlementFacts].

%show all files that are Mach-O executables
getProgramFacts :- file(filePath(X),fileType(Y)),
Y =~ 'Mach-O.*executable',
write('process(filepath("'),write(X),write('")).\n'),
fail.

%show just the file paths
justPaths:- file(filePath(X),fileType(Y)),
Y =~ 'Mach-O.*executable',
writeln(X),
fail.

%outputs all unique entitlement keys required by rules in the container profile.
%TODO: this does not consider negated entitlements (e.g., require-not(require-entitlement(X)))
%TODO: for now this works with container, but eventually it should work on a larger collection of sandbox rules
uniqueRequiredEntitlements:- 
  [container],
  setof(Ent,
    %this syntax tells prolog not to consider Operation, Filters, or Values when determining if the match is unique
    %I only want unique entitlement keys, so I did not tell prolog to ignore Ent when determining uniqueness.
    Operation^Filters^Value^(
      allow(Operation,Filters),
      member(require-entitlement(Ent,Value),Filters)
    ),
    Out),
  member(B,Out),
  writeln(B),
  fail.

containerEnt:-
  %[systemEntitlementFacts],
  process(filePath(Path),entitlement(key("com.apple.private.security.container-required"),_)),
  write("usesSandbox(processPath(\""),write(Path),writeln("\"),profile(\"container\"),mechanism(entitlementKey(\"com.apple.private.security.container-required\")))."),
  fail.

seatbeltEnt:-
  %[systemEntitlementFacts],
  process(filePath(Path),entitlement(key("seatbelt-profiles"),value([string(Value)]))),
  %the container2 profile does not exist and is always overridden by the container profile
  Value \= "container2",
  write("usesSandbox(processPath(\""),write(Path),write("\"),profile(\""),write(Value),writeln("\"),mechanism(entitlementKey(\"seatbelt-profiles\")))."),
  fail.

%I can't just use entitlement facts here because not all executables have entitlements.
pathBasedProfile:-
  [appleProgramSignatures],
  %[systemEntitlementFacts],
  setof(Path,
    (
      processSignature(filePath(Path),_),
      Path =~ '.*/mobile/Containers/Bundle.*'
    ),Pathset),
  member(X,Pathset),
  write("usesSandbox(processPath(\""),write(X),writeln("\"),profile(\"container\"),mechanism(pathBased(\".*/mobile/Containers/Bundle.*\")))."),
  fail.

%this one seems to produce duplicates. I should detect and remove them.
selfAppliedProfile:-
  [stringsFromPrograms],
  setof(Path,
  (
      processString(filePath(Path),stringFromProgram("_sandbox_init"))
      %write("usesSandbox(processPath(\""),
      %write(X),
      %writeln("\"),profile(\"unknown\"),mechanism(selfApplied(\"_sandbox_init\"))).")
    ;
      processString(filePath(Path),stringFromProgram("_sandbox_apply_container"))
      %write("usesSandbox(processPath(\""),
      %write(X),
      %writeln("\"),profile(\"unknown\"),mechanism(selfApplied(\"_sandbox_apply_container\"))).")
  ),Out),
  member(X,Out),
  write("usesSandbox(processPath(\""),
  write(X),
  writeln("\"),profile(\"unknown\"),mechanism(selfApplied))."),
  fail.

pathsToEntCheckers:-
  [stringsFromPrograms],
  setof(Path,processString(filePath(Path),stringFromProgram("_SecTaskCopyValueForEntitlement")),Out),
  member(X,Out),
  writeln(X),
  fail.

%getting the profiles this way seems to have gained one more fact. Maybe there is an executable with multiple mechanisms?
getProfilesFromFacts:-
  [systemEntitlementFacts],
  %I should double check why this works, but it seems to give me what I expect by trying to satisfy both queries in every possible way.
  %the ; represents an OR operation, but because we are pushing to failure, maybe this is what I want according to DeMorgen's law.
  (seatbeltEnt; containerEnt; pathBasedProfile;selfAppliedProfile).



%output csv for path and bundle id
identifiers:- 
  [appleProcessIdentifierFacts],
  process(filepath(X),identifier(Y)),
  write(X),write(","),writeln(Y),
  fail.


%show all entitlements detected
%setof returns a list of unique items that match X.
%I'm not sure what Y's role is in setof.
uniqueEntitlements:- setof(X,A^Y^process(Y,entitlement(key(X),A)),Out),
member(Z,Out), writeln(Z),
fail.

uniqueUsers:- 
  [fileMetaDataFacts],
  setof(X,Y^file(Y,ownerUserName(X)),Out),
  member(Z,Out), writeln(Z),
  fail.

processUsers:- 
  [fileMetaDataFacts],
  [appleProcessIdentifierFacts],
  file(filepath(X),_,_,_,_,_,permissionBits(A),_,ownerUserName(B),_),
  process(filepath(X),identifier(Z)),
  write("processUser(filepath(\""),write(X),
  write("\"),identifier(\""),write(Z),
  write("\"),user(\""),write(B),
  write("\"),permissionBits("),write(A),
  writeln("))."),
  fail.

%this finds programs that don't seem to have any of the sandbox initialization mechanisms we were looking for
%I think that this query is obsolete since I'm not using programToProfileFacts anymore.
findProgramsWithUnknownProfiles:-
  [appleProcessIdentifierFacts],
  [programToProfileFacts],
  findall(A,usesSandbox(processPath(A),_),Known),
  findall(B,process(filepath(B),_),All),
  subtract(All,Known,Unknown),
  member(U,Unknown),
  writeln(U),
  fail.

pathsToSelfAppliedProfiles:-
  [profilesWithMech],
  usesSandbox(processPath(X),_,mechanism(selfApplied)),
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

%interesting negation example. Which apple processes are owned by groups other than wheel and admin?
%file(X,ownerGroupName(Y)), process(X,_),not(Y = "wheel"),not(Y = "admin").

%:- ignore(getProgramFacts),halt.
%:- ignore(justPaths),halt.
%:- ignore(uniqueEntitlements),halt.
%:- ignore(processUsers),halt.
%:- ignore(uniqueUsers),halt.

%this just uses the graph path rules created below.
testPath:-
  [edges],
  %path(start,end,maxLength,result)
  path(1,3,4,Path),
  writeln(Path),
  fail.

%this makes all edges bidirectional.
%should edge direction matter for iOracle?
connected(X,Y) :- edge(X,Y) ; edge(Y,X).

%this code is based on the tutorial at
% https://www.cpp.edu/~jrfisher/www/prolog_tutorial/2_15.html
path(A,B,C,Path) :-
    travel(A,B,[A],Q), 
    %the next two lines limit the maximum size of the path
    length(Q,L),
    L =< C,
    reverse(Q,Path).

travel(A,B,P,[B|P]) :- 
  connected(A,B).
travel(A,B,Visited,Path) :-
  connected(A,C),           
  %the next two lines prevent cycles or infinite loops
  C \== B,
  \+member(C,Visited),
  travel(C,B,[C|Visited],Path).
