%A subject can be either a file or a service (we can define more types if we want to)
subject(X):-
  file(X);
  service(X).

edge(process(X),process(Y)):-
  access(process(X),operation("file-write"),file(File)),
  access(process(Y),operation("file-read"),file(File)).

edge(process(X),process(Y)):-
  access(process(X),operation("mach-lookup"),service(Service)),
  provides(process(Y),service(Service)).

%access to file depends on sandbox and unix permissions
access(process(Proc),operation(Op),file(File)):-
  allow(policy(sandbox),process(Proc),operation(Op),file(File)),
  allow(policy(unixPerm),process(Proc),operation(Op),file(File)).

%access to service depends on sandbox and (optionally) decentralized controls
access(process(Proc),operation(Op),service(Service)):-
  allow(policy(sandbox),process(Proc),operation(Op),service(Service)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SANDBOX POLICY RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%There are sandbox operations that do not have a subject, but I don't think we care about any of them for these abstract queries.

%If the process is not sandboxed then everything is allowed.
allow(policy(sandbox),process(Proc),operation(Op),subject(Subject)):-
  sandboxAssignment(process(Proc),noSandbox).

%default deny sandbox profile.
allow(policy(sandbox),process(Proc),operation(Op),subject(Subject)):-
  %get respective profile
  sandboxAssignment(process(Proc),defaultDeny(Profile)),
  %find relevant rules
  %the output of SandScout should be almost sufficient to match this condition.
  sandboxRule(profile(Profile),operation(Op),filters(Filters)),
  %confirm that the process has the capabilities required for the rule to apply
  %we must also consider the subject when matching certain filters in the requirements
  match(filters(Filters),subject(Subject),process(Proc)).

%default allow sandbox profile.
%This case is a low priority since default allow policies are rare in iOS.
allow(policy(sandbox),process(Proc),operation(Op),subject(Subject)):-
  sandboxAssignment(process(Proc),defaultAllow(Profile)),
  %I don't think this is valid prolog, but it's basicly what we want.
  %The operation is allowed if none of the deny rules match which would default to the allow policy
  not(
    sandboxRule(profile(Profile),operation(Op),filters(Filters)),
    match(filters(Filters),subject(Subject),process(Proc)).
  ).

%I'm assuming the list of filters will not be empty since the subject should be represented by a filter.

%handle list of more than one filter recursively, requiring that all filters in the list be satisfied.
match(filters([Fhead|Ftail]),process(Proc),subject(Subject)):-
  match(filters(Fhead),process(Proc),subject(Subject)),
  match(filters(Ftail),process(Proc),subject(Subject)).

%a list of only one filter is where we can start to get clever.
%we can also specify different types of filter and the conditions necessary for them to be matched.
match(filters([entitlement(Ent)]),process(Proc),subject(Subject)):-
  conditionsToMatchEntitlement.

match(filters([extension(Ext)]),process(Proc),subject(Subject)):-
  conditionsToMatchExtension.

match(filters([literal(Literal)]),process(Proc),subject(Subject)):-
  conditionsToMatchLiteralFilePath.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%UNIX POLICY RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allow(policy(unixPerm),process(Proc),operation(Op),file(File)):-
  hasUser(process(Proc),user(User)),
  unixFileData(file(File),userOwner(Uowner),groupOwner(Gowner),permissions(Permissions)),
  %reference paper and model the 4 conditions that would satisfy the unix permission requirements.
  %it might be easier to reformat our facts than to convert the octal strings into binary in Prolog.
  getRelevantPermissions(operation(Op),permissions(Permissions),relPerm(RelPerm)),
  %is the user an owner, part of the group that owns, or running as root (same as owner?)
  isUserAnOwner(user(User),userOwner(Uowner),groupOwner(Gowner),ownership(Ownership)),
  hasPermission(ownership(Ownership),relPerm()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OPTIONAL DECENTRALIZED CONTROLS POLICY RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Decentralized controls will probably play a minimal role in our graphs since they are very hard to model.
%However, we can still answer a few questions about them.
%The decentralized controls we are aware of regarding privacy settings should not be too much trouble to model.

allow(policy(decentralizedControls),process(Proc),operation(Op),service(Service)):-
  %we should be able to reuse our rules for filters here since they have the same functionality we want
  %we can format them in DNF format as well
  %separate facts for ACL membership and for entitlements that override privacy settings
  knownRequirements(service(Service),filters(Filters)),
  %confirm that the process matches the relevant filters
  %in this case, the subject probably doesn't matter.
  match(filters(Filters),process(Proc),subject(Subject)).

%this is a high level query that the operator might make directly
%it returns the capabilities that might be necessary to access a given service based on references in the process providing the service.
%I should write about this in the paper if we think it will be useful
getDecentralizedControlRequirementReferences(service(Service),capabilities(Capabilities)):-
  provides(process(Provider),service(Service))
  capabilityReferences(process(Provider),capabilities(Capabilities)).

