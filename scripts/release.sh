#!/bin/bash
set -e

VERSION="${1:-1.0.0}"
APP_NAME="MrDefault"
REPO="ronhash10/MrDefault"
DMG_PATH=".build/$APP_NAME-$VERSION.dmg"

# Build the DMG first
echo "🔨 Building DMG..."
bash scripts/build-dmg.sh "$VERSION"

if [ ! -f "$DMG_PATH" ]; then
    echo "❌ DMG not found at $DMG_PATH"
    exit 1
fi

# Create GitHub release
echo "🚀 Creating GitHub release v$VERSION..."
gh release create "v$VERSION" "$DMG_PATH" \
    --repo "$REPO" \
    --title "$APP_NAME v$VERSION" \
    --notes "## $APP_NAME v$VERSION

### Installation

**DMG (recommended):**
1. Download \`$APP_NAME-$VERSION.dmg\`
2. Open the DMG and drag $APP_NAME to Applications
3. Open $APP_NAME from Applications

**Homebrew:**
\`\`\`bash
brew install --cask mrdefault
\`\`\`

### What's New
- Menu bar app for managing default file associations
- Auto-discovers all registered file types
- Pin favorite extensions for quick access
- Launch at Login support
"

echo ""
echo "✅ Release created: https://github.com/$REPO/releases/tag/v$VERSION"

# Calculate SHA for Homebrew cask
SHA256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
echo ""
echo "📝 Homebrew Cask SHA256: $SHA256"
echo "   Update this in Casks/mrdefault.rb"
