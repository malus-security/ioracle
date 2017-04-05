%no parent
filePermissionBits(permissionBits(0),filepath("/")).
%root parent
filePermissionBits(permissionBits(0),filepath("/rootParent")).
%complex name root parent
filePermissionBits(permissionBits(0),filepath("/complex_file+name.txt.whatever")).
%multiple parents
filePermissionBits(permissionBits(0),filepath("/a/one")).
filePermissionBits(permissionBits(0),filepath("/a/two")).
filePermissionBits(permissionBits(0),filepath("/a/one/alpha")).
filePermissionBits(permissionBits(0),filepath("/a/one/beta")).
filePermissionBits(permissionBits(0),filepath("/b/one")).
filePermissionBits(permissionBits(0),filepath("/b/one/alpha")).
