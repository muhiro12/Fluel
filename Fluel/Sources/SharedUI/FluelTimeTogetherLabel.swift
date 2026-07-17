//
//  FluelTimeTogetherLabel.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import MHUI
import SwiftUI

struct FluelTimeTogetherLabel: View {
    private enum Layout {
        static let markOpacity = 0.18
        static let markSize: CGFloat = 26
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @ScaledMetric(relativeTo: .body)
    private var markSize = Layout.markSize

    let text: String

    var body: some View {
        HStack(spacing: designMetrics.spacing.inline) {
            Image(systemName: "clock")
                .imageScale(.small)
                .foregroundStyle(.primary)
                .frame(width: markSize, height: markSize)
                .background(
                    Color.accentColor.opacity(Layout.markOpacity),
                    in: Circle()
                )
                .accessibilityHidden(true)

            Text(text)
                .mhRowValue(colorRole: .primaryText)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    FluelTimeTogetherLabel(text: "4 years, 3 months")
        .mhTheme(.standard)
        .padding()
}
