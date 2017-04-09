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
