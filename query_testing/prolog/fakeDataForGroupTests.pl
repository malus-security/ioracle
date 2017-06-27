:-
  ["../prolog/groups"],
  ["../prolog/users"],
  ["../prolog/unixPermissionsForTests"],
  ["../prolog/unixAllowRules"].

%file ownership
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/none")).
fileOwnerGroupNumber(ownerGroupNumber("12"),filePath("/none")).

fileOwnerUserNumber(ownerUserNumber("501"),filePath("/all")).
fileOwnerGroupNumber(ownerGroupNumber("24"),filePath("/all")).

fileOwnerUserNumber(ownerUserNumber("501"),filePath("/rainbow0123")).
%the effective gid should ignore membership requirements
fileOwnerGroupNumber(ownerGroupNumber("999"),filePath("/rainbow0123")).

fileOwnerUserNumber(ownerUserNumber("501"),filePath("/rainbow4567")).
fileOwnerGroupNumber(ownerGroupNumber("12"),filePath("/rainbow4567")).

fileOwnerUserNumber(ownerUserNumber("501"),filePath("/rainbow3210")).
fileOwnerGroupNumber(ownerGroupNumber("24"),filePath("/rainbow3210")).

fileOwnerUserNumber(ownerUserNumber("501"),filePath("/rainbow7654")).
%the effective gid should ignore membership requirements
fileOwnerGroupNumber(ownerGroupNumber("999"),filePath("/rainbow7654")).

%fake some group membership facts until we get the real thing
groupMembership(user("root"),group("wheel"),groupIDNumber("0")).
groupMembership(user("root"),group("everyone"),groupIDNumber("12")).
groupMembership(user("root"),group("wheel"),groupIDNumber("0")).
groupMembership(user("mobile"),group("mobile"),groupIDNumber("501")).
groupMembership(user("mobile"),group("everyone"),groupIDNumber("12")).
groupMembership(user("_networkd"),group("_networkd"),groupIDNumber("24")).
groupMembership(user("_networkd"),group("everyone"),groupIDNumber("12")).
