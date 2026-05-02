import AppKit
import Foundation

struct AppInfo: Identifiable, Hashable {
    let bundleID: String
    let name: String
    let icon: NSImage
    let url: URL?

    var id: String { bundleID }

    static func from(bundleID: String) -> AppInfo? {
        guard !bundleID.isEmpty else { return nil }

        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            let bundle = Bundle(url: url)
            let name = bundle?.infoDictionary?["CFBundleDisplayName"] as? String
                ?? bundle?.infoDictionary?["CFBundleName"] as? String
                ?? url.deletingPathExtension().lastPathComponent
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            icon.size = NSSize(width: 32, height: 32)
            return AppInfo(bundleID: bundleID, name: name, icon: icon, url: url)
        }

        // App not found — return with generic icon
        let genericIcon = NSWorkspace.shared.icon(for: .application)
        genericIcon.size = NSSize(width: 32, height: 32)
        return AppInfo(bundleID: bundleID, name: bundleID.components(separatedBy: ".").last ?? bundleID, icon: genericIcon, url: nil)
    }
}
