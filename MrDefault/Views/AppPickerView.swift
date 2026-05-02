import SwiftUI

struct AppPickerView: View {
    let extensionName: String
    let currentBundleID: String?
    let onSelect: (String) -> Void

    @ObservedObject private var manager = LaunchServicesManager.shared
    @State private var apps: [AppInfo] = []
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose app for .\(extensionName)")
                .font(.headline)
                .padding(.bottom, 4)

            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Finding apps…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            } else if apps.isEmpty {
                Text("No compatible apps found")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(apps) { app in
                            Button(action: { onSelect(app.bundleID) }) {
                                HStack(spacing: 8) {
                                    Image(nsImage: app.icon)
                                        .resizable()
                                        .frame(width: 24, height: 24)

                                    Text(app.name)
                                        .lineLimit(1)

                                    Spacer()

                                    if app.bundleID == currentBundleID {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .focusable(false)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(app.bundleID == currentBundleID ?
                                          Color.accentColor.opacity(0.1) : Color.clear)
                            )
                        }
                    }
                }
                .frame(height: 200)
            }

            Divider()
                .padding(.top, 4)

            Button(action: browseForApp) {
                HStack {
                    Image(systemName: "folder")
                    Text("Browse…")
                }
            }
            .buttonStyle(.plain)
            .focusable(false)
        }
        .padding(12)
        .frame(width: 280, height: 320)
        .onAppear {
            loadApps()
        }
    }

    private func loadApps() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let result = manager.getCompatibleApps(for: extensionName)
            DispatchQueue.main.async {
                apps = result
                isLoading = false
            }
        }
    }

    private func browseForApp() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.message = "Choose an application to open .\(extensionName) files"

        if panel.runModal() == .OK, let url = panel.url {
            if let bundle = Bundle(url: url), let bundleID = bundle.bundleIdentifier {
                onSelect(bundleID)
            }
        }
    }
}
