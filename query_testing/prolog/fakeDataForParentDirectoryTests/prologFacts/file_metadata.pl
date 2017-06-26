%no parent
filePermissionBits(permissionBits(0),filePath("/")).
%root parent
filePermissionBits(permissionBits(0),filePath("/rootParent")).
%complex name root parent
filePermissionBits(permissionBits(0),filePath("/complex_file+name.txt.whatever")).
%multiple parents
filePermissionBits(permissionBits(0),filePath("/a/one")).
filePermissionBits(permissionBits(0),filePath("/a/two")).
filePermissionBits(permissionBits(0),filePath("/a/one/alpha")).
filePermissionBits(permissionBits(0),filePath("/a/one/beta")).
filePermissionBits(permissionBits(0),filePath("/b/one")).
filePermissionBits(permissionBits(0),filePath("/b/one/alpha")).
