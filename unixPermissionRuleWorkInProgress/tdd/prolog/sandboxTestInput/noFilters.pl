profileRule(profile("mobileProcessProfile"),decision("allow"),operation("noFilterOp"),filters([])).
profileRule(profile("rootProcessProfile"),decision("allow"),operation("noFilterOp"),filters([])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([extension("impossibleExtension")])).
profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([extension("impossibleExtension")])).
