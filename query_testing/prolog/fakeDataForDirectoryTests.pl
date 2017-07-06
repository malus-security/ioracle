:-
  ["../prolog/groups"],
  ["../prolog/users"],
  ["../prolog/directoryPostProcessed/prologFriendlyPermissions"],
  ["../prolog/directoryPostProcessed/dirParents"],
  ["../prolog/unixAllowRules"].

%fake some group membership facts until we get the real thing
groupMembership(user("mobile"),group("mobile"),id("2")).

fileOwnerUserNumber(ownerUserNumber("501"),filePath("/")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/nowrite")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/noread")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/noexec")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/all")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/none")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/all/nowrite")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/all/noread")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/all/noexec")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/none/nowrite")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/none/noread")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/none/noexec")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/all/nowrite/noexec")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/all/noread/nowrite")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/all/noexec/noread")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/none/nowrite/noexec")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/none/noread/nowrite")).
fileOwnerUserNumber(ownerUserNumber("501"),filePath("/none/noexec/noread")).

fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/nowrite")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/noread")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/noexec")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/all")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/none")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/all/nowrite")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/all/noread")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/all/noexec")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/none/nowrite")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/none/noread")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/none/noexec")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/all/nowrite/noexec")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/all/noread/nowrite")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/all/noexec/noread")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/none/nowrite/noexec")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/none/noread/nowrite")).
fileOwnerGroupNumber(ownerGroupNumber("501"),filePath("/none/noexec/noread")).

