mapProcessAppleFiles(Process) :-
	processOwnership(_,_,comm(Process)),
	processSignature(filePath(Process),_).

mapProcessUserGroup(Process,UserName,GroupName) :-
	mapProcessAppleFiles(Process),
	processOwnership(uid(UserId),gid(GroupId),comm(Process)),
	user(userName(UserName),_,userID(UserId),_,_,_,_),
	group(groupName(GroupName),_,id(GroupId),_).

uniqueFile(FilePath) :-
	findall(F, file(filepath(F),_), L),
	list_to_set(L, S),
	member(FilePath, S).

mapProcessPermissions(Process,FilePath,Permission) :-
	mapProcessUserGroup(Process,UserName,GroupName),
	uniqueFile(FilePath),
	file(filepath(FilePath), permissionBits(P)),
	file(filepath(FilePath), ownerUserName(U)),
	file(filepath(FilePath), ownerGroupName(G)),
	(( U = UserName ) -> UserPermission is mod(div(P, 100), 10); UserPermission is mod(P,10)),
	(( G = GroupName ) -> GroupPermission is mod(div(P, 10),10); GroupPermission is mod(P,10)),
	(( UserPermission >= GroupPermission) -> Permission is UserPermission; Permission is GroupPermission).

mapProcessSandboxProfile(Process,SandboxProfile,SandboxMechanism) :-
	mapProcessAppleFiles(Process),
	processOwnership(_,_,comm(Process)),
	usesSandbox(processPath(Process),profile(SandboxProfile),mechanism(SandboxMechanism)).

mapAppleExecSandboxProfile(Executable,SandboxProfile,SandboxMechanism) :-
	processSignature(filePath(Executable),_),
	usesSandbox(processPath(Executable),profile(SandboxProfile),mechanism(SandboxMechanism)).

processAppleNoSandboxProfile(Process) :-
	processOwnership(_,_,comm(Process)),
	processSignature(filePath(Process),_),
	not(usesSandbox(processPath(Process),_,_)).

appleExecNoSandboxProfile(Executable) :-
	processSignature(filePath(Executable),_),
	not(usesSandbox(processPath(Executable),_,_)).
