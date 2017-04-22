%sandboxExtension(filePath("/mobile/process"),extension("commonExtension")).
%sandboxExtension(filePath("/mobile/process"),extension("mobileExtension")).
%sandboxExtension(filePath("/root/process"),extension("commonExtension")).
%sandboxExtension(filePath("/root/process"),extension("rootExtension")).

sandboxExtension(process("/mobile/process"),extension(class("file.read.class"),type("file"),value("/wildcard/readable/file"))).
sandboxExtension(process("/mobile/process"),extension(class("file.write.class"),type("file"),value("/wildcard/writable/file"))).
sandboxExtension(process("/mobile/process"),extension(class("root.class"),type("file"),value("/"))).
sandboxExtension(process("/mobile/process"),extension(class("mach.class"),type("mach"),value("some.mach.service"))).
