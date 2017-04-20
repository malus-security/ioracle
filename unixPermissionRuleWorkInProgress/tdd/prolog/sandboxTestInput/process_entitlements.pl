processEntitlement(filePath("/mobile/process"),entitlement(key("commonBool"),value(bool("true")))).
%I don't think sandscout can handle arrays for entitlement values. I don't think they are used in SBPL either...
processEntitlement(filePath("/mobile/process"),entitlement(key("arrayOfStrings"),value([string("string1"),string("string2")]))).
processEntitlement(filePath("/root/process"),entitlement(key("commonBool"),value(bool("true")))).
processEntitlement(filePath("/root/process"),entitlement(key("rootBool"),value(bool("true")))).
processEntitlement(filePath("/root/process"),entitlement(key("arrayOfStrings"),value([string("string1"),string("string2"),string("string3")]))).
processEntitlement(filePath("/root/process"),entitlement(key("simpleString"),value(string("keyForSimple")))).
