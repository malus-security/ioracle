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
