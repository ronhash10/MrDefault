import Foundation
import UniformTypeIdentifiers
import CoreServices
import AppKit

class LaunchServicesManager: ObservableObject {
    @Published var extensions: [FileExtensionInfo] = []
    @Published var isLoading = false

    static let shared = LaunchServicesManager()

    private let pinnedStore = PinnedExtensionsStore.shared
    private var workspaceObserver: Any?

    init() {
        // Watch for app installs/uninstalls to refresh the list
        workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadAllExtensions()
        }
    }

    deinit {
        if let observer = workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }

    func loadAllExtensions() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let result = self.discoverExtensions()
            DispatchQueue.main.async {
                self.extensions = result
                self.isLoading = false
            }
        }
    }

    private func discoverExtensions() -> [FileExtensionInfo] {
        var seen = Set<String>()
        var result: [FileExtensionInfo] = []

        // 1. Discover from common known extensions
        let commonExtensions = [
            "txt", "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx",
            "jpg", "jpeg", "png", "gif", "bmp", "tiff", "svg", "webp", "heic",
            "mp3", "mp4", "mov", "avi", "mkv", "wav", "flac", "aac", "m4a",
            "html", "css", "js", "ts", "json", "xml", "yaml", "yml",
            "py", "rb", "java", "swift", "c", "cpp", "h", "m", "rs", "go",
            "zip", "tar", "gz", "rar", "7z", "dmg", "iso",
            "md", "rtf", "csv", "log", "sh", "bash", "zsh",
            "app", "pkg", "ipa", "apk",
            "psd", "ai", "sketch", "fig",
            "sql", "db", "sqlite", "tsx", "jsx", "vue", "scss", "less",
            "toml", "ini", "cfg", "conf", "env",
            "dockerfile", "makefile",
            "woff", "woff2", "ttf", "otf", "eot"
        ]

        for ext in commonExtensions {
            seen.insert(ext)
            result.append(makeExtensionInfo(for: ext))
        }

        // 2. Dynamically discover from Launch Services database
        // Query all UTTypes that have file extensions
        let dynamicTypes = discoverFromLaunchServices()
        for ext in dynamicTypes where !seen.contains(ext) {
            seen.insert(ext)
            result.append(makeExtensionInfo(for: ext))
        }

        return result.sorted { $0.id < $1.id }
    }

    private func discoverFromLaunchServices() -> [String] {
        var extensions: [String] = []

        // Get all registered applications and their supported types
        let appDirs = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            URL(fileURLWithPath: NSHomeDirectory() + "/Applications")
        ]

        for dir in appDirs {
            guard let enumerator = FileManager.default.enumerator(
                at: dir,
                includingPropertiesForKeys: [.isApplicationKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { continue }

            for case let url as URL in enumerator {
                guard url.pathExtension == "app" else { continue }
                guard let bundle = Bundle(url: url),
                      let infoPlist = bundle.infoDictionary else { continue }

                // Check CFBundleDocumentTypes for supported extensions
                if let docTypes = infoPlist["CFBundleDocumentTypes"] as? [[String: Any]] {
                    for docType in docTypes {
                        if let exts = docType["CFBundleTypeExtensions"] as? [String] {
                            extensions.append(contentsOf: exts.map { $0.lowercased() })
                        }
                    }
                }
            }
        }

        return Array(Set(extensions)).filter { !$0.isEmpty && $0.count < 10 }
    }

    private func makeExtensionInfo(for ext: String) -> FileExtensionInfo {
        let utType = UTType(filenameExtension: ext)
        let defaultApp = getDefaultApp(for: ext)
        let isPinned = pinnedStore.isPinned(ext)
        return FileExtensionInfo(
            id: ext,
            utType: utType,
            defaultAppBundleID: defaultApp,
            isPinned: isPinned
        )
    }

    func getDefaultApp(for ext: String) -> String? {
        guard let utType = UTType(filenameExtension: ext) else { return nil }
        let contentType = utType.identifier as CFString
        if let handler = LSCopyDefaultRoleHandlerForContentType(contentType, .all) {
            return handler.takeRetainedValue() as String
        }
        // Fallback: try viewer role
        if let handler = LSCopyDefaultRoleHandlerForContentType(contentType, .viewer) {
            return handler.takeRetainedValue() as String
        }
        return nil
    }

    func getCompatibleApps(for ext: String) -> [AppInfo] {
        guard let utType = UTType(filenameExtension: ext) else { return [] }
        let contentType = utType.identifier as CFString

        var bundleIDs: [String] = []
        if let handlers = LSCopyAllRoleHandlersForContentType(contentType, .all) {
            bundleIDs = handlers.takeRetainedValue() as? [String] ?? []
        }

        // Also try NSWorkspace URL-based API for broader results
        let urls = NSWorkspace.shared.urlsForApplications(toOpen: utType)
        for url in urls {
            if let bundle = Bundle(url: url),
               let id = bundle.bundleIdentifier,
               !bundleIDs.contains(id) {
                bundleIDs.append(id)
            }
        }

        return bundleIDs.compactMap { AppInfo.from(bundleID: $0) }
    }

    func setDefaultApp(for ext: String, bundleID: String) -> Bool {
        guard let utType = UTType(filenameExtension: ext) else { return false }
        let contentType = utType.identifier as CFString
        let result = LSSetDefaultRoleHandlerForContentType(contentType, .all, bundleID as CFString)
        if result == noErr {
            if let index = extensions.firstIndex(where: { $0.id == ext }) {
                extensions[index].defaultAppBundleID = bundleID
            }
            return true
        }
        return false
    }

    func togglePin(for ext: String) {
        pinnedStore.togglePin(for: ext)
        if let index = extensions.firstIndex(where: { $0.id == ext }) {
            extensions[index].isPinned = pinnedStore.isPinned(ext)
        }
    }

    var pinnedExtensions: [FileExtensionInfo] {
        extensions.filter { $0.isPinned }
    }
}
