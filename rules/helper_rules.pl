
high_integrity_process(Process):-
  processSignature(filePath(Process),_),
  not(usesSandbox(processPath(Process),profile(_),mechanism(_))).

observed_high_integrity_process(Process):-
  high_integrity_process(Process),
  fileAccessObservation(process(Process),sourceFile(_),destinationFile(_),operation(_)).

high_integrity_paths(Process,File):-
  high_integrity_process(Process),
  (
    (fileAccessObservation(process(Process),sourceFile(File),destinationFile(_),operation(_)))
    ;
    (fileAccessObservation(process(Process),sourceFile(_),destinationFile(File),operation(_)))
  ).

simplified_high_paths(Process,File):-
  not(usesSandbox(processPath(Process),profile(_),mechanism(_))),
  (
    (fileAccessObservation(process(Process),sourceFile(File),destinationFile(_),operation(_)))
    ;
    (fileAccessObservation(process(Process),sourceFile(_),destinationFile(File),operation(_)))
  ).

spit_out_paths_for_dynamic:-
  (
    (fileAccessObservation(process(Path),sourceFile(_),destinationFile(_),operation(_)))
    ;
    (fileAccessObservation(process(_),sourceFile(Path),destinationFile(_),operation(_)))
    ;
    (fileAccessObservation(process(_),sourceFile(_),destinationFile(Path),operation(_)))
    ;
    (processOwnership(uid(_),gid(_),comm(Path)))
    ;
    (sandbox_extension(process(Path),extension(class(_),type(_),value(_))))
    ;
    (sandbox_extension(process(_),extension(class(_),type("file"),value(Path))))
  ),
  writeln(Path),
  fail.

%start simple with just fileAccessObservation processes, then make this more general.
fix_process_strings:-
  (fileAccessObservation(process(Process),sourceFile(_),destinationFile(_),operation(_))),
  symlink_machine(Process,Result),
  writeln(Process),
  writeln(Result).

%base case
symlink_machine("/","/").
  %don't do anything if root directory, just return same thing as result.

symlink_machine(FilePath,Result):-
  %is the current file a symlink?
  fail.
  %consider parent
