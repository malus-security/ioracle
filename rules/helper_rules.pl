% A process is low integrity if it's not high integrity.
low_integrity_process(Process):-
  processSignature(filePath(Process),_),
  not(high_integrity_process(Process)).

%no sandbox profile assigned
high_integrity_process(Process):-
  processSignature(filePath(Process),_),
  not(usesSandbox(processPath(Process),profile(_),mechanism(_))).

%known to run with root authority
high_integrity_process(Process):-
  processOwnership(uid("0"),_,comm(Process)).

%default allow sandbox profile
high_integrity_process(Process):-
  usesSandbox(processPath(Process),profile(Profile),mechanism(_)),
  profileDefault(profile(Profile),decision("allow")).

observed_high_integrity_process(Process):-
  high_integrity_process(Process),
  fileAccessObservation(process(Process),sourceFile(_),destinationFile(_),operation(_)).

high_integrity_paths(File):-
  high_integrity_process(Process),
  (
    (fileAccessObservation(process(Process),sourceFile(File),destinationFile(_),operation(_)))
    ;
    (
      fileAccessObservation(process(Process),sourceFile(_),destinationFile(File),operation(_)),
      not(File == "No destination")
    )
  ).

%do we care whether the file was the source or destination of the operation?
high_integrity_access(Process,File,Operation):-
  high_integrity_process(Process),
  (
    (fileAccessObservation(process(Process),sourceFile(File),destinationFile(_),operation(Operation)))
    ;
    (
      fileAccessObservation(process(Process),sourceFile(_),destinationFile(File),operation(Operation)),
      not(File == "No destination")
    )
  ).


integrity_violations_sand:-
  %fileAccessObservation(process(Proc_obs),sourceFile(File),destinationFile(D_ops),operation(Op_obs)),
  high_integrity_access(AccessProcess,File,AccessOperation),
  usesSandbox(processPath(Process),profile(Profile),mechanism(_)),
  profileDefault(profile("AdSheet"),decision("deny")),
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %Process=="/usr/libexec/afcd",
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(File)),decision(Decision),filters(Filters)),
  write("High Integrity Process		:"), writeln(AccessProcess),
  write("Integrity Violation Type 	:"), writeln(AccessOperation),
  write("Dangerous File Path		:"), writeln(File),
  write("Low Integrity Process		:"), writeln(Process),
  write("Filters Allowing Access	:"), writeln(Filters),
  writeln(""),
  fail.

integrity_violations_unix:-
  %fileAccessObservation(process(Proc_obs),sourceFile(File),destinationFile(D_ops),operation(Op_obs)),
  high_integrity_access(AccessProcess,File,AccessOperation),
  unixAllow(puid("mobile"),pgid("mobile"),coarseOp("write"),file(File)),
  write("High Integrity Process		:"), writeln(AccessProcess),
  write("Integrity Violation Type 	:"), writeln(AccessOperation),
  write("Dangerous File Path		:"), writeln(File),
  write("Low Integrity Process		:"), writeln(Process),
  writeln(""),
  fail.

integrity_violations_both:-
  %fileAccessObservation(process(Proc_obs),sourceFile(File),destinationFile(D_ops),operation(Op_obs)),
  high_integrity_access(AccessProcess,File,AccessOperation),
  unixAllow(puid("mobile"),pgid("mobile"),coarseOp("write"),file(File)),
  usesSandbox(processPath(Process),profile(Profile),mechanism(_)),
  profileDefault(profile("AdSheet"),decision("deny")),
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  %Process=="/usr/libexec/afcd",
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(File)),decision(Decision),filters(Filters)),
  write("integrity_violation( high_process(\""), 	write(AccessProcess),
  write("\"), operation(\""), 				write(AccessOperation),
  write("\"), file_path(\""), 				write(File),
  write("\"), low_process(\""), 			write(Process),
  writeln("\"))."),
  fail.

% Check if process is allowed access to file both by inspecting its sandbox profile and Unix permissions.

% Check if sandboxed process is allowed access by Unix permissions.
process_file_access(process(Process),file(File),coarseOp(Op)):-
  processSignature(filePath(Process),_),
  processCanonicalOwnership(uid(Uid),gid(Gid),processPath(Process)),
  mapCoarseOpToSandboxOp(Op,SandboxOp),
  sandboxAllow(process(Process),file(File),operation(SandboxOp)),
  string_length(File,L),string_codes("/",[Slash|_]), (string_code(L,File,Slash) -> (L1 is L-1,sub_string(File,0,L1,_,ActualFile)) ; ActualFile=File),
  unixAllow(puid(Uid),pgid(Gid),coarseOp(Op),file(ActualFile)).

% Check if unsandboxed process is allowed access by Unix permissions.
process_file_access(process(Process),file(File),coarseOp(Op)):-
  processSignature(filePath(Process),_),
  not(usesSandbox(processPath(Process),profile(_),mechanism(_))),
  processCanonicalOwnership(uid(Uid),gid(Gid),processPath(Process)),
  string_length(File,L),string_codes("/",[Slash|_]), (string_code(L,File,Slash) -> (L1 is L-1,sub_string(File,0,L1,_,ActualFile)) ; ActualFile=File),
  unixAllow(puid(Uid),pgid(Gid),coarseOp(Op),file(ActualFile)).

mapCoarseOpToSandboxOp("read", "file-readSTAR").
mapCoarseOpToSandboxOp("write", "file-writeSTAR").

% Determine process ownership. Fallback to user mobile (UID 501) if no dynamic information from processOwnership predicate.
processCanonicalOwnership(uid(Uid),gid(Gid),processPath(Process)):-
  processOwnership(uid(Uid),gid(Gid),comm(Process)),!.

processCanonicalOwnership(uid(Uid),gid(Gid),processPath(Process)):-
  Uid = "501", Gid = "501",!.
