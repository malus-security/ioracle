%list all unique entitlement keys

%This is a preliminary number that doesn't consider local vs global service names and doesn't consider regex in sandbox filters
listServiceAvailableWithoutEntitlements :-
  relevantRule(
    entitlements([]),
    extensions([]),
    home("/private/var/mobile"),
    profile("container"),
    operation("mach-lookup"),
    %this should actually say object, but I used the wrong variable in the rule.
    subject(machService(MachService)),
    decision(Decision),
    filters(Filters)),
    writeln(MachService),
    fail.

getEntKeys :-
  setof(Key,
    FilePath^Value^(
      processEntitlement(FilePath,entitlement(key(Key),Value))
    ),
    KeyList),
  member(K,KeyList),
  writeln(K),
  fail.

findEntKeyReferences :-
  setof(Key,
    FilePath^Value^(
      processEntitlement(FilePath,entitlement(key(Key),Value))
    ),
    KeyList),
  member(K,KeyList),
  processString(filePath(Path),stringFromProgram(K)),
  write(Path),write(","),writeln(K),
  fail.

findKeyRefForSingleServiceProviders :-
  %set of processes with one service
  setof(Proc,
    Service^Conn^(
      dynamic_service_observation(scanned_proc(Proc),direction("receiving"),Service,Conn)
    ),
    %I don't think these cuts are really doing anything. 
    %I suppose that even without the cut Prolog won't backtrack these operations.
    ProcList),!,

  setof(Key,
    FilePath^Value^(
      processEntitlement(FilePath,entitlement(key(Key),Value))
    ),
    KeyList),!,

  member(P,ProcList),
  setof(Service,
    Conn^(
      dynamic_service_observation(scanned_proc(P),direction("receiving"),service(Service),Conn)
    ),
    ServiceList),
  length(ServiceList,ServiceCount),
  %I think this is what I want, but I can try == if this doesn't seem to be working. Test for correctness.
  ServiceCount=1,

  %I'm using findall because it can still return an empty list even if it fails.
  %This feature allows us to also output executables providing services, but not referencing any entitlements.
  findall(K,
    (member(K,KeyList),
    processString(filePath(P),stringFromProgram(K))),
    KList),

  %ServiceList should only contain one service.
  %KList can contain 0 or more entitlement keys (something is probably wrong if none of the KLists are empty).
  %The commas in KList could cause trouble for other scripts that use this output (it is not a well formatted CSV), but we can modify it as needed.
  write(P),write(","),write(ServiceList),write(","),writeln(KList),
  fail.

%same as findKeyRefForSingleServiceProviders, but requiring 0 ent references instead of requiring 1 provided service
listProvidersWithoutChecks :-
  setof(Proc,
    Service^Conn^(
      dynamic_service_observation(scanned_proc(Proc),direction("receiving"),Service,Conn)
    ),
    %I don't think these cuts are really doing anything. 
    %I suppose that even without the cut Prolog won't backtrack these operations.
    ProcList),!,

  setof(Key,
    FilePath^Value^(
      processEntitlement(FilePath,entitlement(key(Key),Value))
    ),
    KeyList),!,

  member(P,ProcList),
  setof(Service,
    Conn^(
      dynamic_service_observation(scanned_proc(P),direction("receiving"),service(Service),Conn)
    ),
    ServiceList),

  %I'm using findall because it can still return an empty list even if it fails.
  %This feature allows us to also output executables providing services, but not referencing any entitlements.
  findall(K,
    (member(K,KeyList),
    processString(filePath(P),stringFromProgram(K))),
    KList),

  %For now, I only want to see providers and services that do not reference any entitlement keys
  length(KList,KCount),
  KCount=0,

  %KList should contain 0.
  write(P),write(","),write(ServiceList),write(","),writeln(KList),
  fail.
