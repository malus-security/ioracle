:-
  ["../prolog/groups"],
  ["../prolog/users"],
  ["../prolog/unixPermissionsForTests"],
  ["../prolog/unixAllowRules"].

%file ownership
fileOwnerUserName(ownerUserName("mobile"),filePath("/none")).
fileOwnerGroupName(ownerGroupName("everyone"),filePath("/none")).

fileOwnerUserName(ownerUserName("mobile"),filePath("/all")).
fileOwnerGroupName(ownerGroupName("networkd"),filePath("/all")).

fileOwnerUserName(ownerUserName("mobile"),filePath("/rainbow0123")).
%the effective gid should ignore membership requirements
fileOwnerGroupName(ownerGroupName("effectiveGroup"),filePath("/rainbow0123")).

fileOwnerUserName(ownerUserName("mobile"),filePath("/rainbow4567")).
fileOwnerGroupName(ownerGroupName("everyone"),filePath("/rainbow4567")).

fileOwnerUserName(ownerUserName("mobile"),filePath("/rainbow3210")).
fileOwnerGroupName(ownerGroupName("networkd"),filePath("/rainbow3210")).

fileOwnerUserName(ownerUserName("mobile"),filePath("/rainbow7654")).
%the effective gid should ignore membership requirements
fileOwnerGroupName(ownerGroupName("effectiveGroup"),filePath("/rainbow7654")).

%fake some group membership facts until we get the real thing
groupMembership(user("root"),group("root"),id("1")).
groupMembership(user("root"),group("everyone"),id("2")).
groupMembership(user("root"),group("wheel"),id("1")).
groupMembership(user("mobile"),group("mobile"),id("2")).
groupMembership(user("mobile"),group("everyone"),id("2")).
groupMembership(user("networkd"),group("networkd"),id("3")).
groupMembership(user("networkd"),group("everyone"),id("4")).
