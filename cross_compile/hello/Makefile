GCC=/Applications/Xcode.app/Contents/Developer/usr/bin/gcc

SDK=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS10.3.sdk

#pretty sure about this based on examples.  iPhone5s is definitely arm64
ARCH=armv7

SOURCE=hello.c


sb1: $(SOURCE)


	$(GCC) -arch $(ARCH) -isysroot $(SDK) $(SOURCE) -o hello.executable
