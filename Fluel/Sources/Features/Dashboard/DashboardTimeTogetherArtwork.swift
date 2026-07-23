//
//  DashboardTimeTogetherArtwork.swift
//  Fluel
//
//  Created by Codex on 2026/07/23.
//

import MHUI
import SwiftUI

struct DashboardTimeTogetherArtwork: View {
    private enum Layout {
        static let aspectRatio: CGFloat = 1.5
    }

    @Environment(\.mhTheme)
    private var theme

    let timeTogether: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .mhForegroundStyle(.surfaceMuted)
                .aspectRatio(Layout.aspectRatio, contentMode: .fit)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.inline) {
                Text("Time together")
                    .mhTextStyle(.metadata, colorRole: .secondaryText)

                Text(timeTogether)
                    .mhTextStyle(.summaryTitle)
            }
            .padding(theme.spacing.content)
        }
        .accessibilityElement(children: .combine)
    }
}
