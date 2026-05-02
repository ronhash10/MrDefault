#!/bin/bash
set -e

APP_NAME="MrDefault"
VERSION="${1:-1.0.0}"
BUILD_DIR=".build/release"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_DIR=".build/dmg"

echo "🔨 Building $APP_NAME v$VERSION (release)..."
swift build -c release

echo "📦 Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "$APP_NAME/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Update version in Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP_BUNDLE/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$APP_BUNDLE/Contents/Info.plist"

echo "💿 Creating DMG..."
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"
cp -R "$APP_BUNDLE" "$DMG_DIR/"

# Create a symlink to /Applications for drag-install
ln -s /Applications "$DMG_DIR/Applications"

# Create the DMG
rm -f ".build/$DMG_NAME"
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    ".build/$DMG_NAME"

rm -rf "$DMG_DIR"

echo ""
echo "✅ Done!"
echo "   App bundle: $APP_BUNDLE"
echo "   DMG: .build/$DMG_NAME"
echo ""
echo "📝 To create a GitHub release:"
echo "   gh release create v$VERSION .build/$DMG_NAME --title \"$APP_NAME v$VERSION\" --notes \"Release v$VERSION\""
