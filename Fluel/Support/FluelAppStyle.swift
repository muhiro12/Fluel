import FluelLibrary
import MHUI
import SwiftUI

enum FluelAppStyle {
    static let tintColor = Color.accentColor
    static let theme = MHTheme.standard
}

extension View {
    func fluelAppStyle() -> some View {
        tint(FluelAppStyle.tintColor)
            .mhTheme(FluelAppStyle.theme)
            .mhGlassPolicy(.enabled)
    }
}

extension EntryActivityKind {
    var fluelBadgeStyle: MHBadgeStyle {
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
