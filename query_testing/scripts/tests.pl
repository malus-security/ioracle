unixRunAsRoot:-
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("0"),pgid("0"),coarseOp("read"),file(File)),
  writeln(File),
  fail.

userRead:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("501"),pgid("501"),coarseOp("read"),file(File)),
  writeln(File),
  fail.

userWrite :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("501"),pgid("501"),coarseOp("write"),file(File)),
  writeln(File),
  fail.

userExecute :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("501"),pgid("501"),coarseOp("execute"),file(File)),
  writeln(File),
  fail.

groupRead:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("24"),pgid("999"),coarseOp("read"),file(File)),
  writeln(File),
  fail.

groupWrite :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("24"),pgid("999"),coarseOp("write"),file(File)),
  writeln(File),
  fail.

groupExecute :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("24"),pgid("999"),coarseOp("execute"),file(File)),
  writeln(File),
  fail.

otherRead:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("-2"),pgid("-1"),coarseOp("read"),file(File)),
  writeln(File),
  fail.

otherWrite:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("-2"),pgid("-1"),coarseOp("write"),file(File)),
  writeln(File),
  fail.

otherExecute:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("-2"),pgid("-1"),coarseOp("execute"),file(File)),
  writeln(File),
  fail.

dirExecute:-
  ["../prolog/fakeDataForDirectoryTests"],
  fileOwnerUserNumber(_,filePath(File)),
  dirExecute(puid("501"),pgid("501"),coarseOp("execute"),file(File)),
  writeln(File),
  fail.

processAttributes:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  Process = "/mobile/process",
  %entitlements and extensions should return lists, since we don't know how many there will be or how many the rules will require
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  write("getAttributes(process("),write(Process),write("),entitlements("),write(Ent),write("),extensions("),write(Ext), write("),user("),write(User),write("),home("),
  write(Home),write("),profile("),write(Profile),writeln("))."),
  fail.

noFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/noFilters"],
  Process = "/mobile/process",
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

extensionFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/extensionFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

entitlementFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/entitlementFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

literalFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/literalFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  Subject = file("/subjectFile"),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

regexFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/regexFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  Subject = file("/subjectFile"),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

subpathFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/subpathFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  Subject = file("/subject/file/child/grandchild"),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

prefixFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/prefixFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  Subject = file("/mobile/home/dirForUser/fileForUser"),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

%wild means the subject is an unbound variable
wildSubject:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/wildSubject"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  existingFile(ExistingFile),
  Subject = file(ExistingFile),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write(Process),write(","),writeln(ExistingFile),
  fail.

vnodeFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/vnodeFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  vnodeType(Subject,_),
  Subject = file(SubjectString),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write(Process),write(","),writeln(SubjectString),
  fail.

requireNot:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/requireNot"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  vnodeType(Subject,_),
  Subject = file(SubjectString),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write(Process),write(","),writeln(SubjectString),
  fail.

machLiteral:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/machLiteral"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  mach(_,machServices(ServiceList)),
  member(MachName,ServiceList),
  Subject = machService(MachName),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write(Process),write(","),writeln(MachName),
  fail.

machRegex:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/machRegex"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  mach(_,machServices(ServiceList)),
  member(MachName,ServiceList),
  Subject = machService(MachName),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write(Process),write(","),writeln(MachName),
  fail.

sandboxExtensions_files:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/sandboxExtensions_files"],
  Process = "/mobile/process",
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  existingFile(ExistingFile),
  Subject = file(ExistingFile),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write(Op),write(","),writeln(ExistingFile),
  fail.

sandboxExtensions_mach:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/sandboxExtensions_mach"],
  Process = "/mobile/process",
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  mach(_,machServices(ServiceList)),
  member(MachName,ServiceList),
  Subject = machService(MachName),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  writeln(MachName),
  fail.

%I believe this tests our ability to find relevant rules containing regex filters even when the subject variable is unbound
freeRegexFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/regexFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.


