# Homebrew Cask formula for MrDefault
# Host this in a repo: ronhash10/homebrew-mrdefault
#
# Users install with:
#   brew tap ronhash10/mrdefault
#   brew install --cask mrdefault

cask "mrdefault" do
  version "1.0.0"
  sha256 "c2a648ba6f71f8b16e08074eba4220f31166081258a05051a6cf7c0ad6697975"

  url "https://github.com/ronhash10/MrDefault/releases/download/v#{version}/MrDefault-#{version}.dmg"
  name "MrDefault"
  desc "Menu bar app for managing default file associations on macOS"
  homepage "https://github.com/ronhash10/MrDefault"

  depends_on macos: ">= :ventura"

  app "MrDefault.app"

  zap trash: [
    "~/Library/Preferences/com.mrdefault.app.plist",
  ]
end
