%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GENERIC TERMS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%A subject can be either a file or a service (we can define more generic terms if we want to)
subject(X):-
  file(X);
  service(X).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GRAPH RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if we make a graph, then we can define edges based on file access this way.
edge(process(X),process(Y)):-
  access(process(X),operation("file-write"),file(File)),
  access(process(Y),operation("file-read"),file(File)).

%if we make a graph, then we can define edges based on service access this way.
edge(process(X),process(Y)):-
  access(process(X),operation("mach-lookup"),service(Service)),
  provides(process(Y),service(Service)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FINDING NAME RESOLUTION ATTACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%we want to look for file paths where an attacker could attack high integrity processes that access those file paths.
%It would also be helpful to know which processes could write to those files and who the victim high integrity process is.
%The VictimBehavior represents the type of operation the victim performs on the compromised file path (e.g., read, exec, etc.)
possibleNameTraversalAttack(file(File), process(Attacker), process(Victim), operation(VictimBehavior)):-
  lowIntegrity(process(Attacker)),
  highIntegrity(process(Victim)),

  %does our behavior analysis record show the Victim accessing the file? 
  %this will also bind the specific type of access we saw to the VictimBehavior
  %we can make the end result of our filemon analysis produce facts like these
  observedBehavior(file(File),process(Victim),operation(VictimBehavior)),

  %does the Attacker process have write access to the file?
  %we will need to defin and access rule that consider sandbox and unix permissions
  access(process(Attacker),operation('file-write'),file(File)),

  %determine if the attacker can predict the file path
  %this requires that the path is either non random 
  %or Attacker process is allowed to read the directory contents to learn the path
  canPredictPath(process(Attacker),file(File)).


%I'm planning to assume any sandboxed process is of low integrity
lowIntegrity(process(Process)):-
  usesSandbox(processPath(Process),_,_).

%We want to say that a high integrity process is an unsandboxed process
highIntegrity(process(Process)):-
  %the \+ should represent negation. 
  %prolog will try to find a matching fact through exhaustive search.
  %if it can't, then it will return true.
  %we should only use negation for small fact collections like this one because of the exhaustive search.
  %otherwise we would need to create a fact collection listing unsandboxed processes.
  \+ usesSandbox(processPath(Process),_,_). 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FILE PATH PREDICTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%we can determine which paths are consistent by running them on 2 identical devices 
%and taking the intersection of the file paths observed in the file access behavior traces.
%those paths that appear twice are not random and can be predicted by the attacker.
canPredictPath(_,file(Path)):-
  consistentPath(file(Path)).

%if the attacker is able to read the parent directory of the file path,
%they can learn the path of the file and write to it before the Victim does.
%It's ok if this might require a race condition since jailbreakers can still exploit race conditions.
canPredictPath(process(Process),file(Path)):-
  %we need to define a rule that figures out a file's parent directory.
  %this should be easy to do with a regular expression.
  getParentDirectory(file(Path),file(ParentDir)),
  %I'm assuming that there isn't a special sandbox operation for finding out the names of files in a directory.
  access(process(Process),operation('file-read'),file(ParentDir)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ACCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  hasPermission(ownership(Ownership),relPerm()),
  %I think that we should also confirm that the user has execute permission on all directories in the path.
  %This should be straightforward if we combine it with getParentDirectory and make it recursive.
  parentDirectoriesExecutable(user(User),file(File)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OPTIONAL DECENTRALIZED CONTROLS POLICY RULES
%THESE ARE NOT NECESSARY FOR US TO FIND POTENTIAL NAME RESOLUTION ATTACKS
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

