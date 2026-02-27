#!/bin/bash
set -e

SDK="iphoneos"
ARCH="arm64"
FRAMEWORK_NAME="CarTool"
BUILD_DIR="build"
SOURCE_DIR="CarTool/Source"
INCLUDE_DIR="include"

mkdir -p "$BUILD_DIR/$FRAMEWORK_NAME.framework/Headers"

echo "Building Singularity CarTool for $SDK ($ARCH)..."

# Compilation
xcrun -sdk $SDK clang++ -dynamiclib -arch $ARCH \
    -install_name "@rpath/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME" \
    -fobjc-arc -O3 \
    -isysroot $(xcrun -sdk $SDK --show-sdk-path) \
    -I"$SOURCE_DIR" -I"$INCLUDE_DIR" \
    -framework Foundation -framework UIKit -framework CoreGraphics -framework ImageIO \
    "$SOURCE_DIR/CTPacker.mm" \
    "$SOURCE_DIR/CTUnpacker.mm" \
    "$SOURCE_DIR/CTAttributeMapping.mm" \
    -o "$BUILD_DIR/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME"

# Header installation
cp "$SOURCE_DIR/"*.h "$BUILD_DIR/$FRAMEWORK_NAME.framework/Headers/"
cp "$INCLUDE_DIR/CoreUI/CoreUI.h" "$BUILD_DIR/$FRAMEWORK_NAME.framework/Headers/" || true

# Info.plist creation
cat << EOP > "$BUILD_DIR/$FRAMEWORK_NAME.framework/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.$FRAMEWORK_NAME</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>5.0</string>
    <key>CFBundleVersion</key>
    <string>5</string>
    <key>MinimumOSVersion</key>
    <string>12.0</string>
</dict>
</plist>
EOP

echo "Successfully built Singularity $FRAMEWORK_NAME.framework"
