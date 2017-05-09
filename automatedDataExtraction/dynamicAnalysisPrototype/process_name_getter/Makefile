GCC=/Applications/Xcode.app/Contents/Developer/usr/bin/gcc

SDK=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS10.3.sdk
INC_PATH = -I/usr/include

#pretty sure about this based on examples.  iPhone5s is definitely arm64
#ARCH=armv7
ARCH=arm64

SOURCE=process_name_getter.c


sb1: $(SOURCE)

	$(GCC) -arch $(ARCH) -isysroot $(SDK) $(SOURCE) -o process_name_getter.executable
