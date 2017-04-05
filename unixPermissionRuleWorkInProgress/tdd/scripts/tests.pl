unixRunAsRoot:-
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("root"),pgid("wheel"),coarseOp("read"),file(File)),
  fail.

userRead:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("mobile"),pgid("mobile"),coarseOp("read"),file(File)),
  fail.

userWrite :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("mobile"),pgid("mobile"),coarseOp("write"),file(File)),
  fail.

userExecute :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("mobile"),pgid("mobile"),coarseOp("execute"),file(File)),
  fail.

groupRead:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("networkd"),pgid("effectiveGroup"),coarseOp("read"),file(File)),
  fail.

groupWrite :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("networkd"),pgid("effectiveGroup"),coarseOp("write"),file(File)),
  fail.

groupExecute :- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("networkd"),pgid("effectiveGroup"),coarseOp("execute"),file(File)),
  fail.

otherRead:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("nobody"),pgid("nogroup"),coarseOp("read"),file(File)),
  fail.

otherWrite:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("nobody"),pgid("nogroup"),coarseOp("write"),file(File)),
  fail.

otherExecute:- 
  ["../prolog/fakeDataForGroupTests"],
  unixAllow(puid("nobody"),pgid("nogroup"),coarseOp("execute"),file(File)),
  fail.

dirParent:-
  ["../prolog/fakeDataForDirectoryTests"],
  fileOwnerUserName(_,filepath(File)),
  getParentDir(file(File),parent(Parent)),
  %todo output in format that won't get clobbered by uniq
  writeln(Parent),
  fail.
  
