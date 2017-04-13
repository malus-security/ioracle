%facts about available mach-services
mach(pId("com.apple.process1"),machServices(["service1A","service1B"])).
mach(pId("com.apple.process2"),machServices(["service2A"])).
mach(pId("com.apple.process3"),machServices(["service3A","service3B","service3C"])).

%sandbox rules
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([local-name-regex("^.*B$"/i)])).
%there might be rules for services that don't exist, so this is a good test case
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([local-name-regex("^impossible.*$"/i)])).

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([global-name-regex("^.*2.*$"/i)])).
%there might be rules for services that don't exist, so this is a good test case
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("mach-lookup"),filters([global-name-regex("^impossible.*$"/i)])).
