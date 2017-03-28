%:-
%  use_module(library(regex)),
%  [process_ownership].

%for now I can test by using the process with path "/usr/sbin/BTServer" which runs as mobile
allow(policy(unixPerm),process(Proc),operation(Op),file(File)):-
  hasUser(process(Proc),user(User)),
  writeln(User),
  getGroup(user(User),group(Group)),
  writeln(Group),
  unixFileData(file(File),userOwner(UOwner),groupOwner(Gowner),permissions(Permissions)),
  %reference paper and model the 4 conditions that would satisfy the unix permission requirements.
  %it might be easier to reformat our facts than to convert the octal strings into binary in Prolog.
  getRelevantCoarseOp(coarseOp(Cop),operation(Op)),
  getRelevantPermissions(coarseOp(Cop),permissions(Permissions),uownBit(Ubit),gownBit(Gbit),worldBit(Wbit)),
  %is the user an owner, part of the group that owns, or running as root (same as owner?)
  %There are four conditions under which the process can access the file
  (
    User = "root";
    %TODO what if the owner is denied access even though world or group bit is accessible?
    %TODO what if members of the file's group are not allowed to access the file?
    Wbit = 1;
    (Gbit = 1, Gowner = Group);
    %technically the process could chmod the permissions if it owns the file, but I don't think we are modelling this
    %it's also possible that the sandbox is preventing the process from chmodding the file anyway.
    %could a sandboxed process cause trouble by calling chgrp?
    (Ubit = 1, User = UOwner)
  ),
  writeln(File).
  %I think that we should also confirm that the user has execute permission on all directories in the path.
  %This should be straightforward if we combine it with getParentDirectory and make it recursive.
  %parentDirectoriesExecutable(user(User),file(File)).

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

%no permissions
filePermissionBits(permissionBits(0),filepath("/none")).
%all permissions
filePermissionBits(permissionBits(7777),filepath("/all")).
%one and two digits
filePermissionBits(permissionBits(4),filepath("/onedigit")).
filePermissionBits(permissionBits(35),filepath("/twodigit")).
%rainbow pattern
filePermissionBits(permissionBits(0123),filepath("/rainbow0123")).
filePermissionBits(permissionBits(4567),filepath("/rainbow4567")).
filePermissionBits(permissionBits(3210),filepath("/rainbow3210")).
filePermissionBits(permissionBits(7654),filepath("/rainbow7654")).
