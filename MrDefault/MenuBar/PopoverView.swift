import SwiftUI

struct PopoverView: View {
    @ObservedObject private var manager = LaunchServicesManager.shared
    @ObservedObject private var loginManager = LoginItemManager.shared
    var openMainWindow: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("MrDefault")
                    .font(.headline)
                Spacer()
                Button(action: openMainWindow) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                }
                .buttonStyle(.borderless)
                .focusable(false)
                .help("Open full window")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Pinned extensions
            if manager.isLoading {
                VStack(spacing: 8) {
                    Spacer()
                    ProgressView()
                    Text("Loading extensions…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else if manager.pinnedExtensions.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "pin.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No pinned extensions")
                        .foregroundColor(.secondary)
                    Text("Open the full window to pin extensions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(manager.pinnedExtensions) { ext in
                            ExtensionRow(extensionID: ext.id, compact: true)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            Divider()

            // Footer
            HStack {
                Toggle("Launch at Login", isOn: $loginManager.isEnabled)
                    .toggleStyle(.checkbox)
                    .font(.caption)
                    .focusable(false)

                Spacer()

                Button("Open All Extensions…") {
                    openMainWindow()
                }
                .buttonStyle(.plain)
                .focusable(false)
                .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 340, height: 420)
        .onAppear {
            manager.loadAllExtensions()
        }
    }
}
