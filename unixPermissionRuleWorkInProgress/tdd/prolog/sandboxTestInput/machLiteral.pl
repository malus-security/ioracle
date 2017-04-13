%facts about available mach-services
mach(pId("com.apple.process1"),machServices(["service1A","service1B"])).
mach(pId("com.apple.process2"),machServices(["service2A"])).
mach(pId("com.apple.process3"),machServices(["service3A","service3B","service3C"])).

%sandbox rules
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([global-name("service1B")])).
%there might be rules for services that don't exist, so this is a good test case
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([global-name("impossible.global.service")])).

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([local-name("service2A")])).
%there might be rules for services that don't exist, so this is a good test case
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([local-name("impossible.local.service")])).
