%we need a way to deal with randomized file paths if we want to use this effectively.
%maybe we could run the dynamic analysis twice to determine which paths are consistent.
%maybe there are race conditions that can exploited by learning the file path to replace with a symlink.
%the most susceptible looking target seems to be /usr/libexec/crash_mover.
dynamic_permission_change_name_resolution:-
  %root authorized confused deputy
  processOwnership(uid("0"),_,comm(Process)),
  (
    fileAccessObservation(process(Process),sourceFile(File),destinationFile("No destination"),operation("Chowned"))
    ;
    fileAccessObservation(process(Process),sourceFile(File),destinationFile("No destination"),operation("Changed stat"))
  ),
  dirParent(parent(Parent),child(File)), 
  unixAllow(puid("501"),pgid("501"),coarseOp("write"),file(Parent)),
  writeln(""),
  write("Deputy: "),writeln(Process),
  write("File: "),writeln(File),
  write("Directory: "),writeln(Parent),
  fail.

dynamic_permission_change_name_resolution_sandbox:-
  %root authorized confused deputy
  high_integrity_process(ConfusedDeputy), 
  (
    fileAccessObservation(process(ConfusedDeputy),sourceFile(File),destinationFile("No destination"),operation("Chowned"))
    ;
    fileAccessObservation(process(ConfusedDeputy),sourceFile(File),destinationFile("No destination"),operation("Changed stat"))
  ),
  dirParent(parent(Parent),child(File)), 
  unixAllow(puid("501"),pgid("501"),coarseOp("write"),file(Parent)),
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %sandbox requires write access to the file in order to replace it. As opposed to unix permissions which care about write access to the parent directory.
  %TODO we should also include the vnode type of the subject somewhere since we know that the addressbook cares about vnode type.
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(File)),decision(Decision),filters(Filters)),
  writeln(""),
  write("Deputy: "),writeln(ConfusedDeputy),
  write("File: "),writeln(File),
  write("Directory: "),writeln(Parent),
  write("Attacker Process: "),writeln(Process),
  write("Profile : "),writeln(Profile),
  write("Filters : "),writeln(Filters),
  fail.



%assuming the attacker has escaped the sandbox and is running as mobile, where can it deploy a name resolution attack against a chown or chmod operation?
static_permission_change_name_resolution:-
  functionCalled(filePath(ConfusedDeputy),function(Function),parameter(File)), 
  dirParent(parent(Parent),child(File)), 
  unixAllow(puid("501"),pgid("501"),coarseOp("write"),file(Parent)),
  writeln(""),
  write("Deputy: "),writeln(ConfusedDeputy),
  write("Filepath: "),writeln(File),
  write("Function: "),writeln(Function),
  fail.

%same as above but also considerring the sandbox
static_permission_change_name_resolution_sandbox:-
  high_integrity_process(ConfusedDeputy), 
  functionCalled(filePath(ConfusedDeputy),function(Function),parameter(File)), 
  dirParent(parent(Parent),child(File)), 
  unixAllow(puid("501"),pgid("501"),coarseOp("write"),file(Parent)),
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %sandbox requires write access to the file in order to replace it. As opposed to unix permissions which care about write access to the parent directory.
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(File)),decision(Decision),filters(Filters)),
  writeln(""),
  write("Deputy: "),writeln(ConfusedDeputy),
  write("Filepath: "),writeln(File),
  write("Function: "),writeln(Function),
  write("Attacker Process: "),writeln(Process),
  write("Profile : "),writeln(Profile),
  write("Filters : "),writeln(Filters),
  fail.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TRIAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%we can use these two queries if we want to, but it's a lot faster to just use grep and sed to look the relevant executables...
%we know that the Media directory is a low integrity directory subject to lots of attacks, so we would like to triage out the high integrity processes was can use as confused deputies
triage_media:-
  high_integrity_process(Process), 
  processString(filePath(Process),stringFromProgram(ReferencedString)), 
  ReferencedString =~ '.*Media/.*', 
  write("media_triage(process(\""),write(Process),writeln("\"))."), 
  fail.
%we know that the tmp directory is a low integrity directory accessible to afcd's sandbox and used by many processes, so we would like to triage out the high integrity processes was can use as confused deputies
triage_tmp:-
  high_integrity_process(Process), 
  processString(filePath(Process),stringFromProgram(ReferencedString)), 
  ReferencedString =~ '.*tmp/.*', 
  write("tmp_triage(process(\""),write(Process),writeln("\"))."), 
  fail.

%todo make query to determine which directories are accessible to afcd assuming attacker has bypassed the Media/ interface restrictions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXTENSIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%self grantable unlimited 
self_grantable_unrestricted_extensions:-
profileRule(profile(Profile),decision("allow"),operation(Op),filters([extension-class(Ext)])),profileRule(profile(Profile),decision("allow"),operation(Op2),filters(Filters2)),member(extension(Ext),Filters2),
  write("Profile: "),writeln(Profile),
  write("Extension: "),writeln(Ext),
  write("Operation1: "),writeln(Op),
  write("Operation2: "),writeln(Op2),
  write("Filters: "),writeln(Filters2),
  writeln(""),
  fail.

%name resolution attack against extension granter
%extension_name_resolution:-
%  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
%  member( ,Ext),
%  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(File)),decision(Decision),filters(Filters)),
