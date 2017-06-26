profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([prefix(variable("HOME"),path("/dirForUser"))])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([prefix(variable("HOME"),path(""))])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([prefix(variable("HOME"),path("/impossible/file"))])).

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([prefix(variable("HOME"),path("/dirForUser"))])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([prefix(variable("HOME"),path("/dirForUser/fileForUser"))])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([prefix(variable("HOME"),path("/impossible/file"))])).
