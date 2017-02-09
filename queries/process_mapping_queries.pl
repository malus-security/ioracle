mapProcessAppleFiles(Process) :-
	processOwnership(_,_,comm(Process)),
	processSignature(filePath(Process),_).

mapProcessUserGroup(Process,UserName,GroupName) :-
	mapProcessAppleFiles(Process),
	processOwnership(uid(UserId),gid(GroupId),comm(Process)),
	user(userName(UserName),_,userID(UserId),_,_,_,_),
	group(groupName(GroupName),_,id(GroupId),_).

mapProcessPermissions(Process, FilePath, Permission) :-
	mapProcessUserGroup(Process,UserName,GroupName),
	file(FilePath, permissionBits(P)),
	file(FilePath, ownerUserName(U)),
	file(FilePath, ownerGroupName(G)),
	( U = UserName, UserPermission is mod(div(P, 100), 10); UserPermission is mod(P,10)),
	( G = GroupName, GroupPermission is mod(div(P, 10),10); GroupPermission is mod(P,10)),
	( UserPermission >= GroupPermission, Permission is UserPermission; Permission is GroupPermission).

mapProcessSandboxProfile(Process,SandboxProfile,SandboxMechanism) :-
	mapProcessAppleFiles(Process),
	processOwnership(_,_,comm(Process)),
	usesSandbox(processPath(Process),profile(SandboxProfile),mechanism(SandboxMechanism)).
