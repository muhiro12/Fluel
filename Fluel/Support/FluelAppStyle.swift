import FluelLibrary
import SwiftUI

enum FluelAppStyle {
    static let tintColor = Color.accentColor
}

extension View {
    func fluelAppStyle() -> some View {
        tint(FluelAppStyle.tintColor)
    }
}

extension EntryActivityKind {
    var fluelBadgeKind: FluelBadgeKind {
        switch self {
        case .added:
            .positive
        case .updated:
            .accent
        case .archived:
            .warning
        }
    }
}
