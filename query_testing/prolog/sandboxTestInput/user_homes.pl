%home(user("501"),filePath("/mobile/home/")).
%home(user("0"),filePath("/root/home/")).
user(userName("root"),passwordHash("*"),userID("0"),groupID("0"),comment("System Administrator"),homeDirectory("/root/home"),shell("/bin/sh")).
user(userName("mobile"),passwordHash("*"),userID("501"),groupID("501"),comment("Mobile User"),homeDirectory("/mobile/home"),shell("/bin/sh")).
