#maybe I should be running this inside /Applications/Xcode.app/Contents

# there another version I can try here
GCC=/Applications/Xcode.app/Contents/Developer/usr/bin/gcc

#I’m pretty confident about this part.  8.1 should still compile to work on 7.0
SDK=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS10.2.sdk

#pretty sure about this based on examples.  iPhone5s is definitely arm64
ARCH=arm64

SOURCE=getfacl.c


machFinder: $(SOURCE)


	$(GCC) -arch $(ARCH) -isysroot $(SDK) $(SOURCE) -o getfacl

#the code signing stuff seems to be optional.
#maybe this is because of the Pangu jailbreak.
#Just don’t forget to chmod +x any executables I make
