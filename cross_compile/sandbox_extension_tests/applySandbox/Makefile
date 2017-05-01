#maybe I should be running this inside /Applications/Xcode.app/Contents

# there another version I can try here
GCC=/Applications/Xcode.app/Contents/Developer/usr/bin/gcc

#This line has to be updated with each major iOS change.
#iPhoneOSX.Y.sdk where X and Y are the numbers corresponding to the iOS version. 
SDK=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS10.3.sdk

#pretty sure about this based on examples.  iPhone5s is definitely arm64
ARCH=armv7

SOURCE=mySb1.c


sb1: $(SOURCE)

	$(GCC) -arch $(ARCH) -isysroot $(SDK) $(SOURCE) -o sandbox_exec

#the code signing stuff seems to be optional.
#maybe this is because of the Pangu jailbreak.
#Just don’t forget to chmod +x any executables I make
