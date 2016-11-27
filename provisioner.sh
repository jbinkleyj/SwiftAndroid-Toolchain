#!/bin/sh

echo --- initial setup
sudo apt-get update
sudo apt-get install -y curl autoconf automake libtool git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config libblocksruntime-dev libcurl4-openssl-dev

echo --- install NDK
curl -LOs https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip
unzip android-ndk-r13b-linux-x86_64.zip
export ANDROID_NDK_HOME=$HOME/android-ndk-r13b
export PATH=$HOME/android-ndk-r13b/:$PATH

echo --- build libiconv and libicu
git clone https://github.com/SwiftAndroid/libiconv-libicu-android.git
cd libiconv-libicu-android
./build.sh
cd 

echo --- update cmake
wget https://cmake.org/files/v3.4/cmake-3.4.3.tar.gz
tar -xzvf cmake-3.4.3.tar.gz
cd cmake-3.4.3/
./configure --prefix=/usr/local
make
sudo make install
cd

echo --- get swift sources
mkdir swift
cd swift
git clone https://github.com/apple/swift.git
./swift/utils/update-checkout --clone 

echo --- build swift-android toolchain
./swift/utils/build-script \
    -R \
    --android \
    --android-ndk $ANDROID_NDK_HOME \
    --android-api-level 21 \
    --android-icu-uc           $HOME/libiconv-libicu-android/armeabi-v7a \
    --android-icu-uc-include   $HOME/libiconv-libicu-android/armeabi-v7a/icu/source/common \
    --android-icu-i18n         $HOME/libiconv-libicu-android/armeabi-v7a \
    --android-icu-i18n-include $HOME/libiconv-libicu-android/armeabi-v7a/icu/source/i18n/ \
    --foundation \
    --llbuild \
    --lldb \
    --xctest \
    --swiftpm \
    -- \
    --install-libdispatch \
    --install-swift \
    --install-lldb \
    --install-llbuild \
    --install-foundation \
    --install-swiftpm \
    --install-xctest \
    --install-prefix=/usr \
    '--swift-install-components=autolink-driver;compiler;clang-builtin-headers;stdlib;swift-remote-mirror;sdk-overlay;dev' \
    --build-swift-static-stdlib \
    --build-swift-static-sdk-overlay \
    --install-destdir=$HOME/swift-install \
    --installable-package=$HOME/SwiftAndroid.tar.gz 
cd

echo --- Make a test swift program
echo "print(\"Hello Android!\")" > hello.swift

echo --- Link android gold into /usr/bin
sudo ln -s $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin/ld.gold /usr/bin/armv7-none-linux-androideabi-ld.gold

echo --- Hack around swiftc not finding the right linker \(temporary\)
sudo mv /usr/bin/ld.gold /usr/bin/ld.gold-orig
sudo ln -s $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin/ld.gold /usr/bin/ld.gold

echo --- Build sample program
./swift/build/Ninja-ReleaseAssert/swift-linux-x86_64/bin/swiftc \
    -target armv7-none-linux-androideabi \
    -sdk $ANDROID_NDK_HOME/platforms/android-21/arch-arm \
    -L   $ANDROID_NDK_HOME/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a \
    -L   ./android-ndk-r13b/toolchains/x86_64-4.9/prebuilt/linux-x86_64/lib/gcc/x86_64-linux-android/4.9.x/ \
    hello.swift

echo --- copy toolchain to host
cp -r SwiftAndroid.tar.gz /vagrant

cd $HOME
rm -rf android-ndk-r13b-linux-x86_64.zip 
