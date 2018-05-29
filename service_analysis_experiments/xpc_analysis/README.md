It seems that we can invoke exposed xpc methods on iOS by using an app compiled with Xcode.
This required jumping through very many hoops.

The app we used is located here:
https://drive.google.com/file/d/18v1EbcnAg5MCIRrXwI8kc8U0HbFlDP9f/view?usp=sharing

We also had to modify a header file in the Xcode libraries.
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/Foundation.framework/Headers/NSXPCConnection.h`
```
72c72

< - (instancetype)initWithMachServiceName:(NSString *)name options:(NSXPCConnectionOptions)options;

---

> - (instancetype)initWithMachServiceName:(NSString *)name options:(NSXPCConnectionOptions)options __IOS_PROHIBITED __WATCHOS_PROHIBITED __TVOS_PROHIBITED;

143c143

< - (instancetype)initWithMachServiceName:(NSString *)name NS_DESIGNATED_INITIALIZER;

---

> - (instancetype)initWithMachServiceName:(NSString *)name NS_DESIGNATED_INITIALIZER __IOS_PROHIBITED __WATCHOS_PROHIBITED __TVOS_PROHIBITED;
```

Mostly I removed the tags prohibiting these methods on iOS.

This site was helpful for finding protocol files, but not all of the methods we're interested in are listed here.
https://github.com/nst/iOS-Runtime-Headers

Debugging:
  I used the following two links to help set up debugging on a jailbroken iOS 10.1 device.
  https://kov4l3nko.github.io/blog/2016-04-27-debugging-ios-binaries-with-lldb/
  https://blog.securityevaluators.com/debugging-ios-applications-a-guide-to-debug-other-developers-apps-c041311498eb


