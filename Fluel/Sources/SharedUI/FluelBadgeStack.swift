//
//  FluelBadgeStack.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct FluelBadgeStack<Content: View>: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let content: () -> Content

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: designMetrics.spacing.inline) {
                content()
            }

            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                content()
            }
        }
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}

#Preview("Badge stack", traits: .sizeThatFitsLayout) {
    FluelBadgeStack {
        Text("Approximate start")
            .mhBadge(style: .neutral)
        Text("Note")
            .mhBadge(style: .neutral)
        Text("Photo")
            .mhBadge(style: .neutral)
    }
    .padding()
    .mhTheme(.standard)
}
