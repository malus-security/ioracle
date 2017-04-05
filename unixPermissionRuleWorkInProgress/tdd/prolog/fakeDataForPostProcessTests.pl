filePermissionBits(permissionBits(0),filepath("/none")).
%all permissions
filePermissionBits(permissionBits(7777),filepath("/all")).
%one and two digits
filePermissionBits(permissionBits(4),filepath("/onedigit")).
filePermissionBits(permissionBits(35),filepath("/twodigit")).
%rainbow pattern
filePermissionBits(permissionBits(0123),filepath("/rainbow0123")).
filePermissionBits(permissionBits(4567),filepath("/rainbow4567")).
filePermissionBits(permissionBits(3210),filepath("/rainbow3210")).
filePermissionBits(permissionBits(7654),filepath("/rainbow7654")).
