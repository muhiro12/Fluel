// swiftlint:disable one_declaration_per_file
import MHUI
import SwiftUI

// swiftlint:disable no_magic_numbers
private enum FluelMHUICompatibilityMetrics {
    static let inlineSpacing: CGFloat = 4
    static let controlSpacing: CGFloat = 12
    static let sectionSpacing: CGFloat = 32
    static let rowAccessorySpacing: CGFloat = 12
    static let controlCornerRadius: CGFloat = 8
}
// swiftlint:enable no_magic_numbers

struct FluelGlassContainer<Content: View>: View {
    private let spacing: CGFloat?
    private let content: Content

    @ViewBuilder var body: some View {
        if #available(iOS 26, *) {
            if let spacing {
                GlassEffectContainer(spacing: spacing) {
                    content
                }
            } else {
                GlassEffectContainer {
                    content
                }
            }
        } else {
            content
        }
    }

    init(
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }
}

extension MHTheme {
    // The published MHUI package keeps its layout tokens internal, so Fluel
    // mirrors the current standard theme values where local layout glue needs them.
    var fluelInlineSpacing: CGFloat { FluelMHUICompatibilityMetrics.inlineSpacing }
    var fluelControlSpacing: CGFloat { FluelMHUICompatibilityMetrics.controlSpacing }
    var fluelSectionSpacing: CGFloat { FluelMHUICompatibilityMetrics.sectionSpacing }
    var fluelRowAccessorySpacing: CGFloat { FluelMHUICompatibilityMetrics.rowAccessorySpacing }
    var fluelControlCornerRadius: CGFloat { FluelMHUICompatibilityMetrics.controlCornerRadius }
}

extension View {
    @ViewBuilder
    func fluelGlassEffectID<Identifier: Hashable & Sendable>(
        _ identifier: Identifier,
        in namespace: Namespace.ID
    ) -> some View {
        if #available(iOS 26, *) {
            glassEffectID(identifier, in: namespace)
        } else {
            self
        }
    }
}
// swiftlint:enable one_declaration_per_file
