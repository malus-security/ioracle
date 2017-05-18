
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


