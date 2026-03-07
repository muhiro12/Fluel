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
    }
}
