
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

find_sym_links:-
  dynamic_parent(parent(Parent),child(Path)),
  sym_smasher(Path,Result),
  fail.

sym_smasher("/","/").

sym_smasher(Path,Path):-
  not(fileType(type("s"),filePath(Path))).

sym_smasher(Path,Result):-
  %do we need a version for when it's not a symlink?
  fileType(type("l"),filePath(Path)),
  %there's no guarantee that result won't also be a directory with parents where the parents are symlinks
  %fileSymLink(symLinkObject("/var/stash/_.943Uv1/Applications"),filePath("/Applications")).
  %we can swap then repeat the previous steps until there is nothing left to resolve
  fileSymLink(symLinkObject(Result),filePath(Path)),
  write("Path     : "),writeln(Path),
  write("Links To : "),writeln(Result).
  %should we instead process from child up until there isn't a child?
  %dynamic_parent(parent(Parent),child(Path)),
  %sym_smasher(Parent,Result).

  %for each link we find, we could step through all file paths that have the 
