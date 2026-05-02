import SwiftUI

struct ExtensionRow: View {
    let extensionID: String
    let compact: Bool

    @ObservedObject private var manager = LaunchServicesManager.shared
    @State private var showingPicker = false

    private var ext: FileExtensionInfo? {
        manager.extensions.first { $0.id == extensionID }
    }

    private var currentApp: AppInfo? {
        guard let bundleID = ext?.defaultAppBundleID else { return nil }
        return AppInfo.from(bundleID: bundleID)
    }

    var body: some View {
        if let ext = ext {
            HStack(spacing: 10) {
                // Extension badge
                Text(ext.displayExtension)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                    .frame(width: 60, alignment: .leading)

                // Type name (full mode only)
                if !compact {
                    Text(ext.typeName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 100, alignment: .leading)
                        .lineLimit(1)
                }

                Spacer()

                // Current default app
                if let app = currentApp {
                    HStack(spacing: 4) {
                        Image(nsImage: app.icon)
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(app.name)
                            .lineLimit(1)
                            .font(.caption)
                    }
                } else {
                    Text("None")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Change button
                Button(action: {
                    showingPicker = true
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .focusable(false)
                .help("Change default app")

                // Pin button (full mode only)
                if !compact {
                    Button(action: {
                        manager.togglePin(for: ext.id)
                    }) {
                        Image(systemName: ext.isPinned ? "pin.fill" : "pin")
                            .font(.caption)
                            .foregroundColor(ext.isPinned ? .accentColor : .secondary)
                    }
                    .buttonStyle(.borderless)
                    .focusable(false)
                    .help(ext.isPinned ? "Unpin" : "Pin to popover")
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, compact ? 12 : 0)
            .popover(isPresented: $showingPicker) {
                AppPickerView(
                    extensionName: ext.id,
                    currentBundleID: ext.defaultAppBundleID
                ) { selectedBundleID in
                    _ = manager.setDefaultApp(for: ext.id, bundleID: selectedBundleID)
                    showingPicker = false
                }
            }
        }
    }
}
