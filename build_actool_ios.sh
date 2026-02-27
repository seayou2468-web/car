#!/bin/bash
set -e

SDK="iphoneos"
ARCH="arm64"
TOOL_NAME="actool_ios"
BUILD_DIR="build_ios"
SOURCE_DIR="CarTool/Source"
TOOLS_DIR="CarTool/Tools"
INCLUDE_DIR="include"

mkdir -p "$BUILD_DIR"

echo "Building iOS-Native $TOOL_NAME for $SDK ($ARCH)..."

# Compilation
xcrun -sdk $SDK clang++ -arch $ARCH \
    -fobjc-arc -O3 \
    -isysroot $(xcrun -sdk $SDK --show-sdk-path) \
    -I"$SOURCE_DIR" -I"$INCLUDE_DIR" \
    -framework Foundation -framework UIKit -framework CoreGraphics -framework ImageIO \
    -undefined dynamic_lookup \
    "$SOURCE_DIR/CTPacker.mm" \
    "$SOURCE_DIR/CTUnpacker.mm" \
    "$SOURCE_DIR/CTAttributeMapping.mm" \
    "$TOOLS_DIR/main.mm" \
    -o "$BUILD_DIR/$TOOL_NAME"

echo "Successfully built iOS-Native $TOOL_NAME in $BUILD_DIR"
