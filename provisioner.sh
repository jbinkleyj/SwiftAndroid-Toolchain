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

echo --- get swift sources
git clone https://github.com/apple/swift.git
./swift/utils/update-checkout --clone --branch swift-3.0-branch

echo --- build swift-android toolchain
./swift/utils/build-script \
    -R \
    --android \
    --android-ndk $ANDROID_NDK_HOME \
    --android-api-level 21 \
    --android-icu-uc /path/to/libicu-android/armeabi-v7a \
    --android-icu-uc-include /path/to/libicu-android/armeabi-v7a/icu/source/common \
    --android-icu-i18n /path/to/libicu-android/armeabi-v7a \
    --android-icu-i18n-include /path/to/libicu-android/armeabi-v7a/icu/source/i18n/

echo --- copy to host
cp -r build/outputs/apk/ /vagrant

cd $HOME
rm -f ./android-ndk-r10e-linux-x86_64.bin ./android-sdk_r24.4.1-linux.tgz
