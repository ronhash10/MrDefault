# MrDefault
Heve you even wondered what app opens your files? Now you will know!  
A lightweight macOS menu bar app for managing default file associations.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Features

- 📋 **See all file associations** — searchable list of every registered file extension and its default app
- 🔄 **One-click change** — quickly change which app opens any file type
- 📌 **Pin favorites** — pin commonly used extensions to the menu bar popover
- 🚀 **Launch at Login** — optionally start with your Mac
- 🔍 **Auto-discovery** — dynamically finds all extensions registered on your system
- 🎯 **Menu bar app** — no dock icon, always accessible from the top bar

## Installation

### Homebrew (recommended)

```bash
brew tap ronhash10/mrdefault
brew install --cask mrdefault
```

### Manual (DMG)

1. Download the latest `.dmg` from [Releases](https://github.com/ronhash10/MrDefault/releases)
2. Open the DMG and drag **MrDefault** to Applications
3. Launch MrDefault from Applications

### Build from source

```bash
git clone https://github.com/ronhash10/MrDefault.git
cd MrDefault
swift build -c release
# The binary is at .build/release/MrDefault
```

## Usage

1. Click the <img src="assets/menubar-icon.png?v=2" alt="menu bar icon" width="16"> icon in your menu bar
2. Your pinned extensions appear in the popover
3. Click the 🔄 button to change the default app for any extension
4. Click "Open All Extensions…" for the full searchable list
5. Use the 📌 button to pin/unpin extensions

## Requirements

- macOS 13 (Ventura) or later
- Not sandboxed (requires Launch Services access)

## Development

```bash
# Build
swift build

# Run
swift build && open .build/debug/MrDefault

# Build DMG for release
bash scripts/build-dmg.sh 1.0.0
```

## License

MIT
