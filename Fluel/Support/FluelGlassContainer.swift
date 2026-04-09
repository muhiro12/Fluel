// swiftlint:disable one_declaration_per_file
import MHUI
import SwiftUI

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
