#!/bin/bash
set -e

SDK="iphoneos"
ARCH="arm64"
LIB_NAME="CarTool"
BUILD_DIR="build"
SOURCE_DIR="CarTool/Source"
INCLUDE_DIR="include"

mkdir -p "$BUILD_DIR"
mkdir -p "$BUILD_DIR/include"

echo "Compiling Ultra Static $LIB_NAME for $SDK ($ARCH)..."

SDK_PATH=$(xcrun -sdk $SDK --show-sdk-path)

# 1️⃣ Compile object files
xcrun -sdk $SDK clang++ -c -arch $ARCH \
    -fobjc-arc -O3 -std=c++17 \
    -isysroot $SDK_PATH \
    -I"$SOURCE_DIR" -I"$INCLUDE_DIR" \
    "$SOURCE_DIR/CTPacker.mm" \
    "$SOURCE_DIR/CTUnpacker.mm" \
    "$SOURCE_DIR/CTAttributeMapping.mm"

# 2️⃣ Create static library
libtool -static \
    CTPacker.o \
    CTUnpacker.o \
    CTAttributeMapping.o \
    -o "$BUILD_DIR/lib$LIB_NAME.a"

# 3️⃣ Copy headers
cp "$SOURCE_DIR/"*.h "$BUILD_DIR/include/"
cp "$INCLUDE_DIR/CoreUI/CoreUI.h" "$BUILD_DIR/include/" || true

# 4️⃣ Clean object files
rm -f *.o

echo "Successfully built lib$LIB_NAME.a"
