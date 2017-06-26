%sandboxExtension(filePath("/mobile/process"),extension("commonExtension")).
%sandboxExtension(filePath("/mobile/process"),extension("mobileExtension")).
%sandboxExtension(filePath("/root/process"),extension("commonExtension")).
%sandboxExtension(filePath("/root/process"),extension("rootExtension")).

sandboxExtension(process("/mobile/process"),extension(class("file.read.class"),type("file"),value("/wildcard/readable/file"))).
sandboxExtension(process("/mobile/process"),extension(class("file.write.class"),type("file"),value("/wildcard/writable/file"))).
sandboxExtension(process("/mobile/process"),extension(class("root.class"),type("file"),value("/"))).

%my understanding is that sandbox extensions for mach services must match literally.
%I've never seen one that looked like a regular expression.
sandboxExtension(process("/mobile/process"),extension(class("mach.1.class"),type("mach"),value("service1A"))).
sandboxExtension(process("/mobile/process"),extension(class("mach.1.class"),type("mach"),value("service1B"))).
sandboxExtension(process("/mobile/process"),extension(class("root.class"),type("mach"),value("service2A"))).
%the following extension class should not appear as being used in the sb profile, so the process should not get to access service3C
sandboxExtension(process("/mobile/process"),extension(class("common.class"),type("mach"),value("service3C"))).
