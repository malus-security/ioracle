:-
  ["../prolog/groups"],
  ["../prolog/users"],
  ["../prolog/refinedDirectoryPermissions"],
  ["../prolog/unixAllowRules"].

%fake some group membership facts until we get the real thing
groupMembership(user("mobile"),group("mobile"),id("2")).

fileOwnerUserName(ownerUserName("mobile"),filepath("/")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/nowrite")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/noread")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/noexec")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/all")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/none")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/all/nowrite")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/all/noread")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/all/noexec")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/none/nowrite")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/none/noread")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/none/noexec")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/all/nowrite/noexec")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/all/noread/nowrite")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/all/noexec/noread")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/none/nowrite/noexec")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/none/noread/nowrite")).
fileOwnerUserName(ownerUserName("mobile"),filepath("/none/noexec/noread")).

fileOwnerGroupName(ownerGroupName("mobile"),filepath("/")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/nowrite")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/noread")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/noexec")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/all")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/none")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/all/nowrite")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/all/noread")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/all/noexec")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/none/nowrite")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/none/noread")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/none/noexec")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/all/nowrite/noexec")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/all/noread/nowrite")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/all/noexec/noread")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/none/nowrite/noexec")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/none/noread/nowrite")).
fileOwnerGroupName(ownerGroupName("mobile"),filepath("/none/noexec/noread")).

