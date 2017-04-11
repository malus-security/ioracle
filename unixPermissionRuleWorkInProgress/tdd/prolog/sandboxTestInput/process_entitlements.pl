processEntitlement(filePath("/mobile/process"),entitlement(key("commonBool"),value(bool("true")))).
processEntitlement(filePath("/mobile/process"),entitlement(key("arrayOfStrings"),value([string("string1"),string("string2")]))).
processEntitlement(filePath("/root/process"),entitlement(key("commonBool"),value(bool("true")))).
processEntitlement(filePath("/root/process"),entitlement(key("rootBool"),value(bool("true")))).
processEntitlement(filePath("/root/process"),entitlement(key("arrayOfStrings"),value([string("string1"),string("string2"),string("string3")]))).
