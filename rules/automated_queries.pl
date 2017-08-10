% We need a way to deal with randomized file paths if we want to use this effectively.
% Maybe we could run the dynamic analysis twice to determine which paths are consistent.
% Maybe there are race conditions that can exploited by learning the file path to replace with a symlink.
% The most susceptible looking target seems to be /usr/libexec/crash_mover.

% Find root processes that can change ownership of a file inside a mobile user owned directory.
% This is part of the evasi0n 7 jailbreak.
dynamic_permission_change_name_resolution:-
  % Deputy is root.
  processOwnership(uid("0"),_,comm(Process)),
  (
    fileAccessObservation(process(Process),sourceFile(File),destinationFile("No destination"),operation("Chowned"));
    fileAccessObservation(process(Process),sourceFile(File),destinationFile("No destination"),operation("Changed stat"))
  ),
  dirParent(parent(Parent),child(File)),
  unixAllow(puid("501"),pgid("501"),coarseOp("write"),file(Parent)),
  write("deputy(\""),write(Process),write("\"),"),
  write("file(\""),write(File),write("\"),"),
  write("directory(\""),write(Parent),write("\")"),
  writeln(""),
  fail.

dynamic_permission_change_name_resolution_sandbox:-
  % Deputy is high integrity process.
  high_integrity_process(ConfusedDeputy),
  (
    fileAccessObservation(process(ConfusedDeputy),sourceFile(File),destinationFile("No destination"),operation("Chowned"));
    fileAccessObservation(process(ConfusedDeputy),sourceFile(File),destinationFile("No destination"),operation("Changed stat"))
  ),
  dirParent(parent(Parent),child(File)),
  unixAllow(puid("501"),pgid("501"),coarseOp("write"),file(Parent)),
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  % Sandboxing requires write access to the file in order to replace it. As opposed to unix permissions which care about write access to the parent directory.
  % TODO: We should also include the vnode type of the subject somewhere since we know that the addressbook cares about vnode type.
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(File)),decision(Decision),filters(Filters)),
  write("deputy(\""),write(ConfusedDeputy),write("\"),"),
  write("file(\""),write(File),write("\"),"),
  write("directory(\""),write(Parent),write("\"),"),
  write("attackerProcess(\""),write(Process),write("\"),"),
  write("profile(\""),write(Profile),write("\"),"),
  write("filters(\""),write(Filters),write("\"),"),
  writeln(""),
  fail.

% Assuming the attacker has escaped the sandbox and is running as mobile, where
% can it deploy a name resolution attack against a chown or chmod operation?
static_permission_change_name_resolution(ConfusedDeputy,File,Function):-
  functionCalled(filePath(ConfusedDeputy),function(Function),parameter(File)),
  dirParent(parent(Parent),child(File)),
  unixAllow(puid("501"),pgid("501"),coarseOp("write"),file(Parent)).

% Same as above but also considerring the sandbox.
static_permission_change_name_resolution_sandbox:-
  high_integrity_process(ConfusedDeputy),
  functionCalled(filePath(ConfusedDeputy),function(Function),parameter(File)),
  dirParent(parent(Parent),child(File)),
  unixAllow(puid("501"),pgid("501"),coarseOp("write"),file(Parent)),
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  % Sandbox requires write access to the file in order to replace it. As opposed to unix permissions which care about write access to the parent directory.
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(File)),decision(Decision),filters(Filters)),
  write("deputy(\""),write(ConfusedDeputy),write("\"),"),
  write("file(\""),write(File),write("\"),"),
  write("function(\""),write(Function),write("\"),"),
  write("attackerProcess(\""),write(Process),write("\"),"),
  write("profile(\""),write(Profile),write("\"),"),
  write("filters(\""),write(Filters),write("\"),"),
  writeln(""),
  fail.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TRIAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We can use these two queries if we want to, but it's a lot faster to just use
% grep and sed to look the relevant executables. We know that the Media
% directory is a low integrity directory subject to lots of attacks, so we would
% like to triage out the high integrity processes was can use as confused
% deputies.
triage_media:-
  high_integrity_process(Process),
  processString(filePath(Process),stringFromProgram(ReferencedString)),
  ReferencedString =~ '.*Media/.*',
  write("media_triage(process(\""),write(Process),writeln("\"))."),
  fail.

% We know that the tmp directory is a low integrity directory accessible to
% afcd's sandbox and used by many processes, so we would like to triage out the
% high integrity processes was can use as confused deputies.
triage_tmp:-
  high_integrity_process(Process),
  processString(filePath(Process),stringFromProgram(ReferencedString)),
  ReferencedString =~ '.*tmp/.*',
  write("tmp_triage(process(\""),write(Process),writeln("\"))."),
  fail.

% TODO: Make query to determine which directories are accessible to afcd assuming attacker has bypassed the Media/ interface restrictions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXTENSIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% self-grantable unlimited
self_grantable_unrestricted_extensions:-
  profileRule(profile(Profile),decision("allow"),operation(Op),filters([extension-class(Ext)])),profileRule(profile(Profile),decision("allow"),operation(Op2),filters(Filters2)),member(extension(Ext),Filters2),
  write("profile(\""),write(Profile),write("\"),"),
  write("extension(\""),write(Ext),write("\"),"),
  write("operation1(\""),write(Op),write("\"),"),
  write("operation2(\""),write(Op2),write("\"),"),
  write("filters(\""),write(Filters2),write("\"),"),
  writeln(""),
  fail.

% name resolution attack against extension granter
%extension_name_resolution:-
%  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
%  member( ,Ext),
%  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(File)),decision(Decision),filters(Filters)),
