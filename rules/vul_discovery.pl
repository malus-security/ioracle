%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXTENSIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%self grantable unrestricted extensions
%this query works pretty well.
%iOS 10.3 Findings:
  %quicklookd can get arbitrary read access.
  %AdSheet can read all but one file
    %I have no idea why this file is singled out. We should investigate on iOS 10, but the file does not exist on my iOS 8 device.
    %/var/mobile/Library/Caches/GeoServices/tguid.bin
%we can be a bit vague about query details in paper, but this query looks for unrestricted granting ability and ways the granted extension can be used to satisfy filters in the same profile.
%It might be interesting to count how many profiles allow self granting extensions though.
  %While it may be by design, it seems like bad access control...

self_grantable_unrestricted_class_extensions:-
  profileRule(profile(Profile),decision("allow"),operation(Op),filters([extension-class(Ext)])),
  profileRule(profile(Profile),decision("allow"),operation(Op2),filters(Filters2)),
  member(extension(Ext),Filters2),
  write("Profile: "),writeln(Profile),
  write("Extension: "),writeln(Ext),
  write("Operation1: "),writeln(Op),
  write("Operation2: "),writeln(Op2),
  write("Filters: "),writeln(Filters2),
  writeln(""),
  fail.

%name resolution attack against extension granter
%this query finds a lot!
%I think we should just count the unique processes that get listed.
%Several appear many times because more than one filepath is susceptible.
%Maybe we can say X processes are susceptible, with some having multiple vulnerable extensions totalling Y potential name resolution attacks.
extension_name_resolution:-
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  member(extension(class(ExtClass),type("file"),value(ExtValue)),Ext),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(ExtValue)),decision("allow"),filters(Filters)),
  write("Process: "),writeln(Process),
  write("Profile: "),writeln(Profile),
  write("ExtensionClass: "),writeln(ExtClass),
  write("ExtensionValue: "),writeln(ExtValue),
  write("Filters: "),writeln(Filters),
  writeln(""),
  fail.

%might be easier to look for subject filters rather than trying all file paths.
%we should also consider the default allow profiles.
simple_write_noreads:-
  setof(WFilter,WF^(profileRule(profile(Profile),decision("allow"),operation("file-writeSTAR"),filters(WF)),member(WFilter,WF)),WFilterList),
  setof(RFilter,RF^(profileRule(profile(Profile),decision("allow"),operation("file-readSTAR"),filters(RF)),member(RFilter,RF)),RFilterList),
  member(Filter,WFilterList),
  not(member(Filter,RFilterList)),
  %this will only find the most obvious cases by using literal file path filters...
  Filter=literal(Path),
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(Path)),decision("allow"),filters(AWFilters)),
  not(relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-readSTAR"),subject(file(Path)),decision("allow"),filters(ARFilters))),
  write("Profile: "),writeln(Profile),
  write("Path : "),writeln(Path),
  write("Target Filter: "),writeln(Filter),
  write("Actual Write Filter: "),writeln(AWFilters),
  writeln(""),
  fail.

write_noreads_manual_analysis_required:-
  setof(WFilter,WF^(profileRule(profile(Profile),decision("allow"),operation("file-writeSTAR"),filters(WF)),member(WFilter,WF)),WFilterList),
  setof(RFilter,RF^(profileRule(profile(Profile),decision("allow"),operation("file-readSTAR"),filters(RF)),member(RFilter,RF)),RFilterList),
  member(Filter,WFilterList),
  not(member(Filter,RFilterList)),
  (
    Filter=regex(_);
    Filter=literal(Path);
    Filter=subpath(Path);
    Filter=regex-prefix(_,_);
    Filter=literal-prefix(_,_);
    Filter=subpath-prefix(_,_)
  ),
  write("Profile: "),writeln(Profile),
  write("Target Filter: "),writeln(Filter),
  write("Actual Write Filter: "),writeln(AWFilters),
  writeln(""),
  fail.

default_deny_write_noreads_use_known_paths:-
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(Path)),decision("allow"),filters(AWFilters)),
  not(relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-readSTAR"),subject(file(Path)),decision("allow"),filters(ARFilters))),
  fileType(_,filePath(Path)),
  write("Profile: "),writeln(Profile),
  write("Process: "),writeln(Process),
  write("Path: "),writeln(Path),
  write("Write Filters: "),writeln(AWFilters),
  writeln(""),
  fail.

%this query identifies the problems with MobileBackup profile very quickly.
default_allow_write_noreads_use_known_paths:-
  getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)),
  not(relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-writeSTAR"),subject(file(Path)),decision("deny"),filters(AWFilters))),
  relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation("file-readSTAR"),subject(file(Path)),decision("deny"),filters(ARFilters)),
  fileType(_,filePath(Path)),
  write("Profile: "),writeln(Profile),
  write("Process: "),writeln(Process),
  write("Path: "),writeln(Path),
  write("Read Filters: "),writeln(ARFilters),
  writeln(""),
  fail.

%keystroke_exfiltration
%this query seems to work pretty well, but it generates a lot of duplicate output.
%we can either make this query cleaner or we can use post processing to remove the duplicates
%the results we're looking for are [vnode-type(tty),regex(/dev/ttyp[a-f0-9]/i)] and [vnode-type(tty),regex(/dev/ptyp[a-f0-9]/i)]
%a few other dev files are returned as potential results, but I don't think these are suitable for passing messages.
keystroke_exfiltration:-
  setof(WFilter,WF^(profileRule(profile("keyboard"),decision("allow"),operation("file-writeSTAR"),filters(WF)),member(WFilter,WF)),WFilterList),
  setof(WFilter,WF^(profileRule(profile("keyboard"),decision("allow"),operation("file-write-data"),filters(WF)),member(WFilter,WF)),WDFilterList),
  setof(RFilter,RF^(profileRule(profile("container"),decision("allow"),operation("file-readSTAR"),filters(RF)),member(RFilter,RF)),RFilterList),
  setof(RFilter,RF^(profileRule(profile("container"),decision("allow"),operation("file-read-data"),filters(RF)),member(RFilter,RF)),RDFilterList),

  (member(Filter,WFilterList) ; member(Filter,WDFilterList)),
  (member(Filter,RFilterList) ; member(Filter,RDFilterList)),

  profileRule(profile("container"),decision("allow"),operation(Rop),filters(RFil)),
  (Rop="file-readSTAR";Rop="file-read-data"),
  member(Filter,RFil),
  not(member(extension(_),RFil)),
  not(member(require-entitlement(_,_),RFil)),

  profileRule(profile("keyboard"),decision("allow"),operation(Wop),filters(WFil)),
  (Wop="file-writeSTAR";Wop="file-write-data"),
  member(Filter,WFil),
  not(member(extension(_),WFil)),
  not(member(require-entitlement(_,_),WFil)),
  
  write("Exfiltration Filter: "),writeln(Filter),
  write("Write filters: "),writeln(WFil),
  write("Read filters: "),writeln(RFil),
  writeln(""),
  fail.

%afcd_dos_targets
%I expect to see files in Recordings/ as suggested targets against Voice Memo app
afcd_dos_targets:-
  %get file paths from dynamic operations (focus on "Modified" operation)
  fileAccessObservation(process(Process),sourceFile(FilePath),destinationFile("No destination"),operation("Modified")),
  %filter out third party processes
  processSignature(filePath(Process),_),
  %filter out only file paths in Media/ 
  stringSubPath("/private/var/mobile/Media/",FilePath),
  write("FilePath: "),writeln(FilePath),
  write("Process: "),writeln(Process),
  writeln(""),
  fail.

%symlink_bypass
%This query is a bit simplified, but it works for 9.3 and find lock_sync as expected.
simple_symlink_bypass:-
  profileRule(profile("container"),decision("allow"),operation("file-writeSTAR"),filters(WFil)),
  Home="/private/var/mobile",
  not(member(extension(_),WFil)),
  not(member(require-entitlement(_,_),WFil)),
  member(Filter,WFil),
  (
    Filter=literal(Path);
    Filter=subpath(Path);
    (Filter=literal-prefix(variable(_),path(PostPath)),string_concat(Home, PostPath, Path));
    (Filter=subpath-prefix(variable(_),path(PostPath)),string_concat(Home, PostPath, Path))
  ),
  stringSubPath("/private/var/mobile/Media/",Path),
  write("Filters: "),writeln(WFil),
  write("Path: "),writeln(Path),
  writeln(""),
  fail.

