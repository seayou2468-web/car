# CarTool Framework

An iOS-compatible framework for creating and extracting `.car` files (Asset Catalogs) without Mac-specific dependencies.

## Features
- Pack `.xcassets` directories into `.car` files.
- Unpack `.car` files into `.xcassets` structures.
- Uses iOS `CoreUI` Private APIs.
- Pure Objective-C/Objective-C++.

## Integration
Build this framework on a Mac (or GitHub Actions `macos-latest`) and include it in your iOS project.

## GitHub Actions Example
```yaml
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build Framework
        run: xcodebuild -project CarTool.xcodeproj -scheme CarTool -sdk iphoneos build
```
