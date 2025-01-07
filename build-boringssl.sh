#!/bin/sh
set -e

build_framework()
{
  ARCH=$1
  SYSROOT=$2
  TARGET_VERSION=$3

  if [ -d build ]; then
  rm -rf build
  fi
  mkdir build
  cd build
  echo "Build for architecture $ARCH for version $TARGET_VERSION"
  cmake -DCMAKE_OSX_SYSROOT=$SYSROOT -DCMAKE_OSX_ARCHITECTURES=$ARCH -DCMAKE_OSX_DEPLOYMENT_TARGET=$TARGET_VERSION ..
  make
  mkdir -p ../$ARCH/openssl.framework/Headers
  libtool -no_warning_for_no_symbols -static -o ../$ARCH/openssl.framework/openssl crypto/libcrypto.a ssl/libssl.a
  cp -r ../include/openssl/* ../$ARCH/openssl.framework/Headers/
  echo "Created openssl.framework for $ARCH"
  cd ..
}

# Check SDK locations

XCODE_DEV_PATH="/Applications/Xcode.app/Contents/Developer"

if command -v xcode-select 2>&1 >/dev/null
then
	XCODE_DEV_PATH=$(xcode-select -p)
	echo "Using Xcode DEV tools at $XCODE_DEV_PATH"
fi

PHONE_SDK="$XCODE_DEV_PATH/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
SIMULATOR_SDK="$XCODE_DEV_PATH/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
ARM64_SIMULATOR_SDK="$XCODE_DEV_PATH/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"

if [ ! -d "$PHONE_SDK" ]; then
  echo "PHONE SDK does not exist at location!"
  exit
fi
if [ ! -d "$SIMULATOR_SDK" ]; then
  echo "SIMULATOR SDK does not exist at location!"
  exit
fi
if [ ! -d "$ARM64_SIMULATOR_SDK" ]; then
  echo "SIMULATOR SDK for ARM64 does not exist at location!"
  exit
fi

# Clone boringSSL

if [ -d boringssl ]; then
rm -rf boringssl
fi

git clone https://boringssl.googlesource.com/boringssl
cd boringssl
boringssl_version=$(git rev-parse --short HEAD)
echo "BoringSSL version: $boringssl_version"

# Build frameworks

build_framework arm64 $PHONE_SDK '15.0'
if [ -d iphoneos ]; then
rm -rf iphoneos
fi
mkdir iphoneos
mv arm64 iphoneos
build_framework x86_64 $SIMULATOR_SDK '15.0'
build_framework arm64 $ARM64_SIMULATOR_SDK '15.0'

# Create universal framework output directory for simulator

if [ -d iphonesimulator ]; then
rm -rf iphonesimulator
fi
mkdir -p iphonesimulator/openssl.framework

# Create universal framework for simulator

echo "Combine simulator archs..."
lipo -create -output "iphonesimulator/openssl.framework/openssl" "arm64/openssl.framework/openssl" "x86_64/openssl.framework/openssl"
cp -r arm64/openssl.framework/Headers iphonesimulator/openssl.framework/

# Create xcframework output directory

if [ -d ../output ]; then
rm -rf ../output
fi
mkdir ../output

# Create xcframework

echo "Create xcframework..."
xcodebuild -create-xcframework -framework iphoneos/arm64/openssl.framework -framework iphonesimulator/openssl.framework -output "../output/openssl.xcframework"

# Cleanup

rm -rf build
rm -rf iphoneos
rm -rf arm64
rm -rf x86_64
rm -rf iphonesimulator
cd ..
echo "Done!"
echo "Created output at "$PWD"/output/"
