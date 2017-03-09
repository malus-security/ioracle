%:-
%  use_module(library(regex)),
%  [process_ownership].

%for now I can test by using the process with path "/usr/sbin/BTServer" which runs as mobile
allow(policy(unixPerm),process(Proc),operation(Op),file(File)):-
  hasUser(process(Proc),user(User)),
  getGroup(user(User),group(Group)),

  unixFileData(file(File),userOwner(UOwner),groupOwner(Gowner),permissions(Permissions)),
  %reference paper and model the 4 conditions that would satisfy the unix permission requirements.
  %it might be easier to reformat our facts than to convert the octal strings into binary in Prolog.
  getRelevantPermissions(operation(Op),permissions(Permissions),relPerm(RelPerm)),
  %is the user an owner, part of the group that owns, or running as root (same as owner?)
  isUserAnOwner(user(User),userOwner(Uowner),groupOwner(Gowner),ownership(Ownership)),
  hasPermission(ownership(Ownership),relPerm()),
  %I think that we should also confirm that the user has execute permission on all directories in the path.
  %This should be straightforward if we combine it with getParentDirectory and make it recursive.
  parentDirectoriesExecutable(user(User),file(File)).

hasUser(process(Proc),user(User)):-
  processOwnership(uid(Uid),_,comm(Proc)),
  user(userName(User),_,userID(Uid),_,_,_,_).

getGroup(user(User),group(Group)):-
  group(groupName(Group),_,_,members(MemberList)),
  member(User,MemberList).

%this rule will change if we change the format of our metadata facts.
unixFileData(file(File),userOwner(UOwner),groupOwner(GOwner),permissions(Permissions)):-
  file(filepath(File),ownerUserName(UOwner)),
  file(filepath(File),ownerGroupName(GOwner)),
  file(filepath(File),permissionBits(Permissions)).
  
