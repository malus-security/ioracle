existingFile("/wildcard/readable/file").
existingFile("/wildcard/writable/file").
existingFile("/some/file").
existingFile("/impossible/file").

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([extension("file.read.class")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([extension("root.class"),literal("/some/file")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-readSTAR"),filters([extension("impossible.class"),literal("/impossible/file")])).

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([extension("file.write.class")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([extension("root.class"),literal("/some/file")])).
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("file-writeSTAR"),filters([extension("impossible.class"),literal("/impossible/file")])).
