profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([extension("commonExtension")])).
profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([extension("rootExtension"),extension("commonExtension")])).

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([extension("impossibleExtension")])).
profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([extension("impossibleExtension")])).

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([extension("impossibleExtension"),extension("commonExtension")])).
profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([extension("impossibleExtension"),extension("rootExtension"),extension("commonExtension")])).

