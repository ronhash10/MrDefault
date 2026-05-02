import Foundation
import UniformTypeIdentifiers

struct FileExtensionInfo: Identifiable, Hashable {
    let id: String // the extension string (e.g. "pdf")
    let utType: UTType?
    var defaultAppBundleID: String?
    var isPinned: Bool

    var displayExtension: String {
        ".\(id)"
    }

    var typeName: String {
        utType?.localizedDescription ?? id.uppercased()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FileExtensionInfo, rhs: FileExtensionInfo) -> Bool {
        lhs.id == rhs.id
    }
}
