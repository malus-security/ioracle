:-
  ["../prolog/groups"],
  ["../prolog/users"],
  ["../prolog/directoryPostProcessed/prologFriendlyPermissions"],
  ["../prolog/directoryPostProcessed/dirParents"],
  ["../prolog/unixAllowRules"].

%fake some group membership facts until we get the real thing
groupMembership(user("mobile"),group("mobile"),id("2")).

fileOwnerUserName(ownerUserName("mobile"),filePath("/")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/nowrite")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/noread")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/noexec")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/all")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/none")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/all/nowrite")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/all/noread")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/all/noexec")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/none/nowrite")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/none/noread")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/none/noexec")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/all/nowrite/noexec")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/all/noread/nowrite")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/all/noexec/noread")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/none/nowrite/noexec")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/none/noread/nowrite")).
fileOwnerUserName(ownerUserName("mobile"),filePath("/none/noexec/noread")).

fileOwnerGroupName(ownerGroupName("mobile"),filePath("/")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/nowrite")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/noread")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/noexec")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/all")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/none")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/all/nowrite")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/all/noread")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/all/noexec")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/none/nowrite")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/none/noread")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/none/noexec")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/all/nowrite/noexec")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/all/noread/nowrite")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/all/noexec/noread")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/none/nowrite/noexec")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/none/noread/nowrite")).
fileOwnerGroupName(ownerGroupName("mobile"),filePath("/none/noexec/noread")).

