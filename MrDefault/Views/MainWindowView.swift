import SwiftUI

struct MainWindowView: View {
    @ObservedObject private var manager = LaunchServicesManager.shared
    @State private var searchText = ""
    @State private var showPinnedOnly = false

    var filteredExtensions: [FileExtensionInfo] {
        var list = manager.extensions
        if showPinnedOnly {
            list = list.filter { $0.isPinned }
        }
        if !searchText.isEmpty {
            list = list.filter {
                $0.id.localizedCaseInsensitiveContains(searchText) ||
                $0.typeName.localizedCaseInsensitiveContains(searchText) ||
                (AppInfo.from(bundleID: $0.defaultAppBundleID ?? "")?.name ?? "")
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar area
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search extensions or apps…", text: $searchText)
                    .textFieldStyle(.plain)

                Button(action: { manager.loadAllExtensions() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .focusable(false)
                .help("Refresh list")

                Toggle(isOn: $showPinnedOnly) {
                    Image(systemName: showPinnedOnly ? "pin.fill" : "pin")
                }
                .toggleStyle(.button)
                .focusable(false)
                .help("Show pinned only")
            }
            .padding(12)

            Divider()

            // Extension list
            if manager.isLoading {
                VStack(spacing: 8) {
                    Spacer()
                    ProgressView()
                    Text("Discovering extensions…")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else if filteredExtensions.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "doc.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No extensions found")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List(filteredExtensions) { ext in
                    ExtensionRow(extensionID: ext.id, compact: false)
                }
                .listStyle(.inset)
            }

            // Status bar
            HStack {
                Text("\(filteredExtensions.count) extensions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if manager.isLoading {
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 550, minHeight: 450)
        .onAppear {
            if manager.extensions.isEmpty {
                manager.loadAllExtensions()
            }
        }
    }
}
