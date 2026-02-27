#!/bin/bash
set -e

SDK="iphoneos"
ARCH="arm64"
LIB_NAME="libCarTool.a"
BUILD_DIR="build"
SOURCE_DIR="CarTool/Source"
INCLUDE_DIR="include"

mkdir -p "$BUILD_DIR/include"

echo "Building iOS Static Library $LIB_NAME for $SDK ($ARCH)..."

# Compilation to object files
xcrun -sdk $SDK clang++ -c -arch $ARCH \
    -fobjc-arc -O3 \
    -isysroot $(xcrun -sdk $SDK --show-sdk-path) \
    -I"$SOURCE_DIR" -I"$INCLUDE_DIR" \
    "$SOURCE_DIR/CTPacker.mm" \
    "$SOURCE_DIR/CTUnpacker.mm" \
    "$SOURCE_DIR/CTAttributeMapping.mm"

# Create static library
xcrun -sdk $SDK ar -rcs "$BUILD_DIR/$LIB_NAME" CTPacker.o CTUnpacker.o CTAttributeMapping.o

# Clean up object files
rm *.o

# Header installation
cp "$SOURCE_DIR/"*.h "$BUILD_DIR/include/"
cp "$INCLUDE_DIR/CoreUI/CoreUI.h" "$BUILD_DIR/include/" || true

echo "Successfully built iOS Static Library: $BUILD_DIR/$LIB_NAME"
echo "Headers installed in: $BUILD_DIR/include"
