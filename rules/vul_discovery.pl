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
  Filter=literal(Path);
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

%symlink_bypass
%won't work on iOS 10


%keystroke_exfiltration

%afcd_dos_targets

