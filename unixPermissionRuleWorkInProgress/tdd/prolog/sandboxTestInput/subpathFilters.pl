profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([subpath("/subject/file/")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([subpath("/subject/file/child/")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([subpath("/impossible/file/")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([subpath("/impossible/file/child/")])).

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([subpath("/subject/file/")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([subpath("/subject/file/child/")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([subpath("/impossible/file/")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([subpath("/impossible/file/child/")])).

