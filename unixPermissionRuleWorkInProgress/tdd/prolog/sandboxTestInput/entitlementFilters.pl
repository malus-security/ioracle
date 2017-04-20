%It should be impossible for an entitlement to have more than one value, so I'm assuming the list following the key can have one value or zero.
%Where zero entitlement values represents the bool true entitlement value.

%should match
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  require-entitlement("commonBool",[])
])).

profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  require-entitlement("commonBool",[]),
  require-entitlement("simpleString",[entitlement-value("keyForSimple")])
])).


%blatantly not match
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  require-entitlement("impossibleBool",[])
])).

profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  require-entitlement("impossibleBool",[])
])).


%match partially, but should not unify.
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  require-entitlement("impossibleBool",[]),
  require-entitlement("commonBool",[])
])).

profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  require-entitlement("impossibleBool",[]),
  require-entitlement("commonBool",[]),
  require-entitlement("simpleString",[entitlement-value("keyForSimple")])
])).

