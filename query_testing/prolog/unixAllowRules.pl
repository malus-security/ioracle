% For now I can test by using the process with path "/usr/sbin/BTServer" which runs as mobile.

unixUserAllow(uid(Uid),coarseOp(Op),file(File)) :-
  fileOwnerUserNumber(ownerUserNumber(Uowner),filePath(File)),
  fileOwnerGroupNumber(ownerGroupNumber(Gowner),filePath(File)),

  getRelBits(coarseOp(Op),file(File),uownBit(Ubit),gownBit(Gbit),worldBit(Wbit)),

  checkPermBits(Uid,Uowner,Gowner,Ubit,Gbit,Wbit).

% Root is always provided access.
checkPermBits(Uid,Uowner,Gowner,Ubit,Gbit,Wbit) :- Uid = "0".
% Check user first. If match found, do not go to other tests.
checkPermBits(Uid,Uowner,Gowner,Ubit,Gbit,Wbit) :- Ubit = 1, Uid = Uowner, !.
% Check group, but make sure user wasn't denied. If match found, do not go to other tests.
checkPermBits(Uid,Uowner,Gowner,Ubit,Gbit,Wbit) :- \+ (Ubit = 0, Uid = Uowner), Gbit = 1, isUserNumberInGroupNumber(Uid,Gowner), !.
% Check others, but make sure user and group weren't denied. If match found, do not go to other tests.
checkPermBits(Uid,Uowner,Gowner,Ubit,Gbit,Wbit) :- \+ (Ubit = 0, Uid = Uowner), \+ (Gbit = 0, isUserNumberInGroupNumber(Uid,Gowner)), Wbit = 1, !.

isUserNumberInGroupNumber(Uid,Gid) :-
  user(userName(U),_,userID(Uid),_,_,_,_),
  groupMembership(user(U),_,groupIDNumber(Gid)).

% I've modified this rule such that it now expects a uid and gid number as input.
unixAllow(puid(Puid),pgid(Pgid),coarseOp(Op),file(File)):-
  fileOwnerUserNumber(ownerUserNumber(Uowner),filePath(File)),
  fileOwnerGroupNumber(ownerGroupNumber(Gowner),filePath(File)),

  getRelBits(coarseOp(Op),file(File),uownBit(Ubit),gownBit(Gbit),worldBit(Wbit)),

  % Expect user test to fail without following line.
  (
    % Check user first. If match found, do not go to other tests.
    (Ubit = 1, Puid = Uowner),fail;
    % Check group, but make sure user wasn't denied. If match found, do not go to other tests.
    (
      \+ (Ubit=0,Puid=Uowner),
      (Gbit = 1, matchGroup(Puid,Pgid,Gowner))
    ),fail;
    % Check others, but make sure user and group weren't denied. If match found, do not go to other tests.
    (
      \+ (Ubit=0,Puid=Uowner),
      \+ (Gbit=0,matchGroup(Puid,Pgid,Gowner)),
      (Wbit = 1)
    ),fail;

    % Will probably need this later.
    %(Gbit = 0, Pgid = Gowner, fail);
    (Puid = "0")
  ).
  %writeln(File).

matchGroup(Puid,Pgid,Gowner):-
  (
    (Pgid=Gowner);
    (
      %I need to get the name for the group id number
      user(userName(User_name),_,userID(Puid),_,_,_,_),
      groupMembership(user(User_name),_,groupIDNumber(Gowner))
    )
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

% This is more an example query than a useful rule.
nonWorldExecutableDirectories(file(File)):-
  fileType(type("d"),filePath(File)),
  otherexecute(0,File),
  writeln(File).

hasUser(process(Proc),user(User)):-
  processOwnership(uid(Uid),_,comm(Proc)),
  user(userName(User),_,userID(Uid),_,_,_,_).

getRelevantCoarseOp(coarseOp(Cop),operation(Op)):-
  (Op = "file-read", Cop = "read");
  (Op = "file-write", Cop = "write").
  %todo list other relevant sandbox operations

%don't call the dirExecute in unixAllow, that might lead to nasty recursion.
%if we want to run them together, we should make a higher level rule that calls them both sequentially.
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

