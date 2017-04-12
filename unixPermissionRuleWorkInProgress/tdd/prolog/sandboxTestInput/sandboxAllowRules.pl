:-
  use_module(library(regex)).

getAttributes(process(Process),entitlements(Ent),extensions(Ext),user(User),home(Home),profile(Profile)):-
  processProfile(filePath(Process),profile(Profile)),
  processOwnership(uid(User),_,comm(Process)),
  findall(X,sandboxExtension(filePath(Process),X),Ext),
  findall(Y,processEntitlement(filePath(Process),Y),Ent),
  home(user(User),filePath(Home)).

getRequirements(profile(Profile)):-
  fail.
  
relevantRule(entitlements(Ent),extensions(Ext),home(Home),profile(Profile),operation(Op),subject(Subject),decision(Decision),filters(Filters)):-
  profileRule(profile(Profile),decision(Decision),operation(Op),filters(Filters)),
  satisfyFilters(filters(Filters),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)).

satisfyFilters(filters([]),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)).

%EXTENSIONS FILTER
%the required sandbox extension must be among those possessed by the process.
satisfyFilters(filters(extension(F_Ext)),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)):-
  member(extension(F_Ext),Ext).

%ENTITLEMENTS FILTER
%the required sandbox extension must be among those possessed by the process.
satisfyFilters(filters(require-entitlement(Key,ValueList)),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)):-
  %get the entitlement from the filter to match the format in our facts
  (
    %value list could be empty or could contain a single string. I haven't seen any other configurations in SBPL
    %however, there are more complex entitlements, so we should we should keep in mind that this might be oversimplified.
    (ValueList = [],Value = bool("true"));
    (ValueList = [entitlement-value(ValueString)],Value = string(ValueString))
  ),
  member(entitlement(key(Key),value(Value)),Ent).

%LITERALS FILTER
satisfyFilters(filters(literal(Literal)),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)):-
  %since the filepath of the subject and the literal must match exactly, this should be sufficient.
  Subject = file(Literal).

%REGEX FILTER
satisfyFilters(filters(regex(Regex)),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)):-
  Subject = file(SubjectString),
  SubjectString =~ Regex.

%SUBPATH FILTER
satisfyFilters(filters(subpath(Subpath)),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)):-
  %There is probably a simpler solution, but I just reused this code from sandscout.
  Subject = file(SubjectString),
  stringSubPath(Subpath,SubjectString).

stringSubPath(SubPathString,FilePathString):-
  atom_codes(SubPathString,SBList),
  atom_codes(FilePathString,FPList),
  spath(SBList,FPList),!.

spath([],_).

spath([SPHead|SPTail],[FPHead|FPTail]):-
  SPHead = FPHead,
  spath(SPTail,FPTail).

%PREFIX FILTER
satisfyFilters(filters(prefix(preVar("HOME"),postPath(PostPath))),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)):-
  %since the filepath of the subject and the literal must match exactly, this should be sufficient.
  Subject = file(SubjectString),
  string_concat(Home, PostPath, SubjectString).


satisfyFilters(filters([Head|Tail]),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)):-
  satisfyFilters(filters(Head),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)),
  satisfyFilters(filters(Tail),entitlements(Ent),extensions(Ext),home(Home),subject(Subject)).


