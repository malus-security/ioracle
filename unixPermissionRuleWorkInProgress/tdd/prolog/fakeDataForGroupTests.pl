:-
  ["../prolog/groups"],
  ["../prolog/users"],
  ["../prolog/unixPermissionsForTests"],
  ["../prolog/unixAllowRules"].

%file ownership
fileOwnerUserName(ownerUserName("mobile"),filepath("/none")).
fileOwnerGroupName(ownerGroupName("everyone"),filepath("/none")).

fileOwnerUserName(ownerUserName("mobile"),filepath("/all")).
fileOwnerGroupName(ownerGroupName("networkd"),filepath("/all")).

fileOwnerUserName(ownerUserName("mobile"),filepath("/rainbow0123")).
%the effective gid should ignore membership requirements
fileOwnerGroupName(ownerGroupName("effectiveGroup"),filepath("/rainbow0123")).

fileOwnerUserName(ownerUserName("mobile"),filepath("/rainbow4567")).
fileOwnerGroupName(ownerGroupName("everyone"),filepath("/rainbow4567")).

fileOwnerUserName(ownerUserName("mobile"),filepath("/rainbow3210")).
fileOwnerGroupName(ownerGroupName("networkd"),filepath("/rainbow3210")).

fileOwnerUserName(ownerUserName("mobile"),filepath("/rainbow7654")).
%the effective gid should ignore membership requirements
fileOwnerGroupName(ownerGroupName("effectiveGroup"),filepath("/rainbow7654")).

%fake some group membership facts until we get the real thing
groupMembership(user("root"),group("root"),id("1")).
groupMembership(user("root"),group("everyone"),id("2")).
groupMembership(user("root"),group("wheel"),id("1")).
groupMembership(user("mobile"),group("mobile"),id("2")).
groupMembership(user("mobile"),group("everyone"),id("2")).
groupMembership(user("networkd"),group("networkd"),id("3")).
groupMembership(user("networkd"),group("everyone"),id("4")).
