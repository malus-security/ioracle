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
%writable_nonreadable:-


%symlink_bypass
%won't work on iOS 10

%keystroke_exfiltration

%afcd_dos_targets

