import Foundation

class PinnedExtensionsStore: ObservableObject {
    static let shared = PinnedExtensionsStore()

    private let key = "pinnedExtensions"

    @Published var pinnedExtensions: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(pinnedExtensions), forKey: key)
        }
    }

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? ["pdf", "txt", "jpg", "png", "html"]
        self.pinnedExtensions = Set(saved)
    }

    func isPinned(_ ext: String) -> Bool {
        pinnedExtensions.contains(ext)
    }

    func togglePin(for ext: String) {
        if pinnedExtensions.contains(ext) {
            pinnedExtensions.remove(ext)
        } else {
            pinnedExtensions.insert(ext)
        }
    }
}
