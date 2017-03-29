user(userName("nobody"),passwordHash("*"),userID("-2"),groupID("-2"),comment("Unprivileged User"),homeDirectory("/var/empty"),shell("/usr/bin/false")).
user(userName("root"),passwordHash("*"),userID("0"),groupID("0"),comment("System Administrator"),homeDirectory("/var/root"),shell("/bin/sh")).
user(userName("mobile"),passwordHash("*"),userID("501"),groupID("501"),comment("Mobile User"),homeDirectory("/var/mobile"),shell("/bin/sh")).
user(userName("daemon"),passwordHash("*"),userID("1"),groupID("1"),comment("System Services"),homeDirectory("/var/root"),shell("/usr/bin/false")).
user(userName("_ftp"),passwordHash("*"),userID("98"),groupID("-2"),comment("FTP Daemon"),homeDirectory("/var/empty"),shell("/usr/bin/false")).
user(userName("_networkd"),passwordHash("*"),userID("24"),groupID("24"),comment("Network Services"),homeDirectory("/var/networkd"),shell("/usr/bin/false")).
user(userName("_wireless"),passwordHash("*"),userID("25"),groupID("25"),comment("Wireless Services"),homeDirectory("/var/wireless"),shell("/usr/bin/false")).
user(userName("_neagent"),passwordHash("*"),userID("34"),groupID("34"),comment("NEAgent"),homeDirectory("/var/empty"),shell("/usr/bin/false")).
user(userName("_securityd"),passwordHash("*"),userID("64"),groupID("64"),comment("securityd"),homeDirectory("/var/empty"),shell("/usr/bin/false")).
user(userName("_mdnsresponder"),passwordHash("*"),userID("65"),groupID("65"),comment("mDNSResponder"),homeDirectory("/var/empty"),shell("/usr/bin/false")).
user(userName("_sshd"),passwordHash("*"),userID("75"),groupID("75"),comment("sshd Privilege separation"),homeDirectory("/var/empty"),shell("/usr/bin/false")).
user(userName("_unknown"),passwordHash("*"),userID("99"),groupID("99"),comment("Unknown User"),homeDirectory("/var/empty"),shell("/usr/bin/false")).
user(userName("_distnote"),passwordHash("*"),userID("241"),groupID("241"),comment("Distributed Notifications"),homeDirectory("/var/empty"),shell("/usr/bin/false")).
user(userName("_astris"),passwordHash("*"),userID("245"),groupID("245"),comment("Astris Services"),homeDirectory("/var/db/astris"),shell("/usr/bin/false")).
