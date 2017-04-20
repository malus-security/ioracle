profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([literal("/subjectFile")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([literal("/impossibleFile")])).

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([literal("/subjectFile")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([literal("/impossibleFile")])).
