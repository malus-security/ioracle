profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([regex("^/subject.*$"/i)])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([regex("^/impossible*$"/i)])).

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([regex("^/subject.*$"/i)])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([regex("^/impossible*$"/i)])).
