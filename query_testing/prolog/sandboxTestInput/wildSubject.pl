%It should be impossible for an entitlement to have more than one value, so I'm assuming the list following the key can have one value or zero.
%Where zero entitlement values represents the bool true entitlement value.

existingFile("/thefile1").
existingFile("/thefile2").
existingFile("/thefile3").
existingFile("/thefile4").
existingFile("/thefile5").
existingFile("/thefile6").
existingFile("/thedir/thefile").

%should match
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  literal("/thefile1"),
  require-entitlement("commonBool",[])
])).

profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  literal("/thefile2"),
  require-entitlement("commonBool",[]),
  require-entitlement("simpleString",[entitlement-value("keyForSimple")])
])).

%should match
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  %ends in 4 or 5, so should match /thefile4 and /thefile5
  regex("^.*[45]$"/i),
  require-entitlement("commonBool",[])
])).

profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  subpath("/thedir/"),
  require-entitlement("commonBool",[]),
  require-entitlement("simpleString",[entitlement-value("keyForSimple")])
])).



%blatantly not match
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  literal("/thefile3"),
  require-entitlement("impossibleBool",[])
])).

profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  literal("/thefile4"),
  require-entitlement("impossibleBool",[])
])).


%match partially, but should not unify.
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  literal("/thefile5"),
  require-entitlement("impossibleBool",[]),
  require-entitlement("commonBool",[])
])).

profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  literal("/thefile6"),
  require-entitlement("impossibleBool",[]),
  require-entitlement("commonBool",[]),
  require-entitlement("simpleString",[entitlement-value("keyForSimple")])
])).

