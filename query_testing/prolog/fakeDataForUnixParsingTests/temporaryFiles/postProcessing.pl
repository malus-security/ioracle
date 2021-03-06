:-
  ["../prolog/unixAllowRules"],
  ["../prolog/groups"],
  ["../prolog/users"],
  ["../prolog/unixPermissionsForTests"].

%no permissions
filePermissionBits(permissionBits(0),filePath("/none")).
%all permissions
filePermissionBits(permissionBits(7777),filePath("/all")).
%one and two digits
filePermissionBits(permissionBits(4),filePath("/onedigit")).
filePermissionBits(permissionBits(35),filePath("/twodigit")).
%rainbow pattern
filePermissionBits(permissionBits(0123),filePath("/rainbow0123")).
filePermissionBits(permissionBits(4567),filePath("/rainbow4567")).
filePermissionBits(permissionBits(3210),filePath("/rainbow3210")).
filePermissionBits(permissionBits(7654),filePath("/rainbow7654")).

spit_out_paths_for_dynamic:-
  (
    (fileAccessObservation(process(Path),sourceFile(_),destinationFile(_),operation(_)))
    ;
    (fileAccessObservation(process(_),sourceFile(Path),destinationFile(_),operation(_)))
    ;
    (fileAccessObservation(process(_),sourceFile(_),destinationFile(Path),operation(_)))
    ;
    (processOwnership(uid(_),gid(_),comm(Path)))
    ;
    (sandbox_extension(process(Path),extension(class(_),type(_),value(_))))
    ;
    (sandbox_extension(process(_),extension(class(_),type("file"),value(Path))))
  ),
  writeln(Path),
  fail.

allFilePaths:-
  filePermissionBits(_,filePath(File)),
  writeln(File),
  fail.

prologFriendlyPermissionFacts:-
  filePermissionBits(permissionBits(Permissions),filePath(File)),
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
