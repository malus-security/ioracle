%facts about available mach-services
mach(pId("com.apple.process1"),machServices(["service1A","service1B"])).
mach(pId("com.apple.process2"),machServices(["service2A"])).
mach(pId("com.apple.process3"),machServices(["service3A","service3B","service3C"])).

%are sb extensions for mach services ever combined with other mach filters?

%I think that this one rule should provide access to two different mach services.
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([extension("mach.1.class")])).
%this extension also provides access to a file, but that should not show up as an available mach service
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([extension("root.class")])).
%the process doesn't have this extension, so this rule should not apply
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([extension("impossible.class")])).
