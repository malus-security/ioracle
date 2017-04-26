%for now I can test by using the process with path "/usr/sbin/BTServer" which runs as mobile
unixAllow(puid(Puid),pgid(Pgid),coarseOp(Op),file(File)):-
  fileOwnerUserName(ownerUserName(Uowner),filePath(File)),
  fileOwnerGroupName(ownerGroupName(Gowner),filePath(File)),

  getRelBits(coarseOp(Op),file(File),uownBit(Ubit),gownBit(Gbit),worldBit(Wbit)),

  %expect user test to fail without following line
  (
    %check user first
    (Ubit = 1, Puid = Uowner);
    %check group, but make sure user wasn't denied
    ( 
      \+ (Ubit=0,Puid=Uowner), 
      (Gbit = 1, matchGroup(Puid,Pgid,Gowner))
    );
    %check group, but make sure user wasn't denied
    ( 
      \+ (Ubit=0,Puid=Uowner), 
      \+ (Gbit=0,matchGroup(Puid,Pgid,Gowner)),
      (Wbit = 1)
    );

    %will probably need this later
    %(Gbit = 0, Pgid = Gowner, fail);
    (Puid = "root")
  ).
  %writeln(File).
  %I think that we should also confirm that the user has execute permission on all directories in the path.
  %This should be straightforward if we combine it with getParentDirectory and make it recursive.
  %parentDirectoriesExecutable(user(User),file(File)).


matchGroup(Puid,Pgid,Gowner):-
  (
    (Pgid=Gowner);
    (groupMembership(user(Puid),group(Gowner),_))
  ).

getRelBits(coarseOp("read"),file(File),uownBit(Ubit),gownBit(Gbit),worldBit(Wbit)):-
  userread(Ubit,File),
  groupread(Gbit,File),
  otherread(Wbit,File).

getRelBits(coarseOp("write"),file(File),uownBit(Ubit),gownBit(Gbit),worldBit(Wbit)):-
  userwrite(Ubit,File),
  groupwrite(Gbit,File),
  otherwrite(Wbit,File).

getRelBits(coarseOp("execute"),file(File),uownBit(Ubit),gownBit(Gbit),worldBit(Wbit)):-
  userexecute(Ubit,File),
  groupexecute(Gbit,File),
  otherexecute(Wbit,File).

nonWorldExecutableDirectories(file(File)):-
  fileType(type("d"),filePath(File)),
  filePermissionBits(permissionBits(Permissions),filePath(File)),
  getRelevantPermissions(coarseOp("execute"),permissions(Permissions),_,_,worldBit(0)),
  writeln(File).

nonWorldExecutableDirectories2(file(File)):-
  fileType(type("d"),filePath(File)),
  otherexecute(0,File),
  writeln(File).

hasUser(process(Proc),user(User)):-
  processOwnership(uid(Uid),_,comm(Proc)),
  user(userName(User),_,userID(Uid),_,_,_,_).

getGroup(user(User),group(Group)):-
  (
    %group based on membership
    (group(groupName(Group),_,_,members(MemberList)),
    member(User,MemberList))
    ;
    %group based on default group
    (user(userName(User),_,userID(Uid),groupID(Gid),_,_,_),
    group(groupName(Group),_,id(Gid),_))
  ).

getRelevantCoarseOp(coarseOp(Cop),operation(Op)):-
  (Op = "file-read", Cop = "read");
  (Op = "file-write", Cop = "write").
  %todo list other relevant sandbox operations

%don't call the dirExecute in unixAllow, that might lead to nasty recursion.
%base case, do I need to cut here?
dirExecute(puid(Puid),pgid(Pgid),coarseOp(Op),file("/")):-
  Op = "execute",
  unixAllow(puid(Puid),pgid(Pgid),coarseOp(Op),file(File)).

%normal case.
dirExecute(puid(Puid),pgid(Pgid),coarseOp(Op),file(File)):-
  File \= "/",
  Op = "execute",
  unixAllow(puid(Puid),pgid(Pgid),coarseOp(Op),file(File)),
  dirParent(parent(Parent),child(File)),
  dirExecute(puid(Puid),pgid(Pgid),coarseOp(Op),file(Parent)).


  %is the current file accessible?

  %what about it's parent?

  %what about the root directory?
