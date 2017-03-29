%:-
%  use_module(library(regex)),
%  [process_ownership].

%for now I can test by using the process with path "/usr/sbin/BTServer" which runs as mobile
unixAllow(puid(Puid),pgid(Pgid),coarseOp(Op),file(File)):-
  fileOwnerUserName(ownerUserName(Uowner),filepath(File)),
  fileOwnerGroupName(ownerGroupName(Gowner),filepath(File)),

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
  ),
  writeln(File).
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
  fileType(type("d"),filepath(File)),
  filePermissionBits(permissionBits(Permissions),filepath(File)),
  getRelevantPermissions(coarseOp("execute"),permissions(Permissions),_,_,worldBit(0)),
  writeln(File).

nonWorldExecutableDirectories2(file(File)):-
  fileType(type("d"),filepath(File)),
  otherexecute(0,File),
  writeln(File).

prologFriendlyPermissionFacts:-
  %[file_metadata],
  filePermissionBits(permissionBits(Permissions),filepath(File)),
  getRelevantPermissions(coarseOp("read"),permissions(Permissions),uownBit(Ubitr),gownBit(Gbitr),worldBit(Wbitr)),
  prettyPrint(File,Ubitr,Gbitr,Wbitr,"read"),
  getRelevantPermissions(coarseOp("write"),permissions(Permissions),uownBit(Ubitw),gownBit(Gbitw),worldBit(Wbitw)),
  prettyPrint(File,Ubitw,Gbitw,Wbitw,"write"),
  getRelevantPermissions(coarseOp("execute"),permissions(Permissions),uownBit(Ubite),gownBit(Gbite),worldBit(Wbite)),
  prettyPrint(File,Ubite,Gbite,Wbite,"execute"),
  getSpecialPermissions(coarseOp("special"),permissions(Permissions),setuid(Suid),setgid(Sgid),stickybit(Sbit)),
  prettyPrint(File,Suid,Sgid,Sbit,"special"),
  fail.
  
prettyPrint(File,Ubit,Gbit,Wbit,Type):-
  write("user"),write(Type),write("("),write(Ubit),write(",\""),write(File),writeln("\")."),
  write("group"),write(Type),write("("),write(Gbit),write(",\""),write(File),writeln("\")."),
  write("other"),write(Type),write("("),write(Wbit),write(",\""),write(File),writeln("\").").
  

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

%this rule will change if we change the format of our metadata facts.
unixFileData(file(File),userOwner(UOwner),groupOwner(GOwner),permissions(Permissions)):-
  file(filepath(File),ownerUserName(UOwner)),
  file(filepath(File),ownerGroupName(GOwner)),
  file(filepath(File),permissionBits(Permissions)).
  
getRelevantCoarseOp(coarseOp(Cop),operation(Op)):-
  (Op = "file-read", Cop = "read");
  (Op = "file-write", Cop = "write").
  %todo list other relevant sandbox operations

%TODO all of the following is probably inefficient.
%Ideally we would have facts that say which files are userReadable, groupReadable, worldReadable, etc.

%read based operations
getSpecialPermissions(coarseOp("special"),permissions(Permissions),setuid(Suid),setgid(Sgid),stickybit(Sbit)):-
  Rel = floor(Permissions/1000),
  Suid is floor(Rel/4),
  Sgid is floor(mod(Rel,4) / 2),
  Sbit is floor(mod(Rel,2)).

getRelevantPermissions(coarseOp("read"),permissions(Permissions),uownBit(Ubit),gownBit(Gbit),worldBit(Wbit)):-
  Rel = mod(Permissions,1000),
  Octal1 is floor(Rel / 100),
  Octal2 is floor(mod(Rel,100) / 10),
  Octal3 is floor(mod(Rel,10)),
  Ubit is floor(Octal1 / 4),
  Gbit is floor(Octal2 / 4),
  Wbit is floor(Octal3 / 4).

getRelevantPermissions(coarseOp("write"),permissions(Permissions),uownBit(Ubit),gownBit(Gbit),worldBit(Wbit)):-
  Rel = mod(Permissions,1000),
  Octal1 is floor(Rel / 100),
  Octal2 is floor(mod(Rel,100) / 10),
  Octal3 is floor(mod(Rel,10)),
  Ubit is floor(mod(Octal1,4) / 2),
  Gbit is floor(mod(Octal2,4) / 2),
  Wbit is floor(mod(Octal3,4) / 2).

getRelevantPermissions(coarseOp("execute"),permissions(Permissions),uownBit(Ubit),gownBit(Gbit),worldBit(Wbit)):-
  Rel = mod(Permissions,1000),
  Octal1 is floor(Rel / 100),
  Octal2 is floor(mod(Rel,100) / 10),
  Octal3 is floor(mod(Rel,10)),
  Ubit is floor(mod(Octal1,2)),
  Gbit is floor(mod(Octal2,2)),
  Wbit is floor(mod(Octal3,2)).

