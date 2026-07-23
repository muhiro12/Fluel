//
//  DashboardTimeTogetherFeature.swift
//  Fluel
//
//  Created by Codex on 2026/07/23.
//

import MHUI
import SwiftUI

struct DashboardTimeTogetherFeature: View {
    @Environment(\.mhTheme)
    private var theme

    let title: String
    let timeTogether: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.control) {
            DashboardTimeTogetherArtwork(timeTogether: timeTogether)

            Text("Longest together right now")
                .mhTextStyle(.metadata, colorRole: .tertiaryText)

            Text(title)
                .mhTextStyle(.summaryTitle)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .mhSurfaceInset()
    }
}
