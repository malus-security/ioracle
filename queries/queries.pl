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
  write("usesSandbox(processPath(\""),write(Path),write("\"),profile(\""),write(Value),writeln("\"),mechanism(entitlementKey(\"seatbelt-profiles\")))."),
  fail.

pathBasedProfile:-
  %[appleProcessIdentifierFacts],
  %[systemEntitlementFacts],
  process(filePath(X),_),
  X =~ '.*/mobile/Containers/Bundle.*',
  write("usesSandbox(processPath(\""),write(X),writeln("\"),profile(\"container\"),mechanism(pathBased(\".*/mobile/Containers/Bundle.*\")))."),
  fail.

%this one seems to produce duplicates. I should detect and remove them.
selfAppliedProfile:-
  [stringsFromPrograms],
  (
      processString(filePath(X),stringFromProgram("_sandbox_init")),
      write("usesSandbox(processPath(\""),
      write(X),
      writeln("\"),profile(\"unknown\"),mechanism(selfApplied(\"_sandbox_init\"))).")
    ;
      processString(filePath(X),stringFromProgram("_sandbox_apply_container")),
      write("usesSandbox(processPath(\""),
      write(X),
      writeln("\"),profile(\"unknown\"),mechanism(selfApplied(\"_sandbox_apply_container\"))).")
  ),
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

findProgramsWithUnknownProfiles:-
  [appleProcessIdentifierFacts],
  [programToProfileFacts],
  findall(A,usesSandbox(processPath(A),_),Known),
  findall(B,process(filepath(B),_),All),
  subtract(All,Known,Unknown),
  member(U,Unknown),
  writeln(U),
  fail.

%interesting negation example. Which apple processes are owned by groups other than wheel and admin?
%file(X,ownerGroupName(Y)), process(X,_),not(Y = "wheel"),not(Y = "admin").

%:- ignore(getProgramFacts),halt.
%:- ignore(justPaths),halt.
%:- ignore(uniqueEntitlements),halt.
%:- ignore(processUsers),halt.
%:- ignore(uniqueUsers),halt.
