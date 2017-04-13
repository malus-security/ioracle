unixRunAsRoot:-
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("root"),pgid("wheel"),coarseOp("read"),file(File)),
  writeln(File),
  fail.

userRead:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("mobile"),pgid("mobile"),coarseOp("read"),file(File)),
  writeln(File),
  fail.

userWrite :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("mobile"),pgid("mobile"),coarseOp("write"),file(File)),
  writeln(File),
  fail.

userExecute :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("mobile"),pgid("mobile"),coarseOp("execute"),file(File)),
  writeln(File),
  fail.

groupRead:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("networkd"),pgid("effectiveGroup"),coarseOp("read"),file(File)),
  writeln(File),
  fail.

groupWrite :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("networkd"),pgid("effectiveGroup"),coarseOp("write"),file(File)),
  writeln(File),
  fail.

groupExecute :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("networkd"),pgid("effectiveGroup"),coarseOp("execute"),file(File)),
  writeln(File),
  fail.

otherRead:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("nobody"),pgid("nogroup"),coarseOp("read"),file(File)),
  writeln(File),
  fail.

otherWrite:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("nobody"),pgid("nogroup"),coarseOp("write"),file(File)),
  writeln(File),
  fail.

otherExecute:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("nobody"),pgid("nogroup"),coarseOp("execute"),file(File)),
  writeln(File),
  fail.

dirExecute:-
  ["../prolog/fakeDataForDirectoryTests"],
  fileOwnerUserName(_,filePath(File)),
  dirExecute(puid("mobile"),pgid("mobile"),coarseOp("execute"),file(File)),
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
  %should we be unifying subjects with some file access records?
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

extensionFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/extensionFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %should we be unifying subjects with some file access records?
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

entitlementFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/entitlementFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %should we be unifying subjects with some file access records?
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

literalFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/literalFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %should we be unifying subjects with some file access records?
  Subject = file("/subjectFile"),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

regexFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/regexFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %should we be unifying subjects with some file access records?
  Subject = file("/subjectFile"),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

subpathFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/subpathFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %should we be unifying subjects with some file access records?
  Subject = file("/subject/file/child/grandchild"),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

prefixFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/prefixFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %should we be unifying subjects with some file access records?
  Subject = file("/mobile/home/fileForUser"),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write("profileRule(profile("),write(Profile),write("),decision("),write(Decision),write("),operation("),write(Op),write("),filters("),write(Filters),writeln("))."),
  fail.

wildSubject:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/wildSubject"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %should we be unifying subjects with some file access records?
  existingFile(ExistingFile),
  Subject = file(ExistingFile),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write(Process),write(","),writeln(ExistingFile),
  fail.

vnodeFilters:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/vnodeFilters"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %should we be unifying subjects with some file access records?
  vnodeType(Subject,_),
  Subject = file(SubjectString),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write(Process),write(","),writeln(SubjectString),
  fail.

requireNot:-
  ["../prolog/sandboxTestInput/fakeDataForSandboxTests"],
  ["../prolog/sandboxTestInput/requireNot"],
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %should we be unifying subjects with some file access records?
  vnodeType(Subject,_),
  Subject = file(SubjectString),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)),
  write(Process),write(","),writeln(SubjectString),
  fail.
