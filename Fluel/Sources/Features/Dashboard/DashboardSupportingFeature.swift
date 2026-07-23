//
//  DashboardSupportingFeature.swift
//  Fluel
//
//  Created by Codex on 2026/07/23.
//

import FluelLibrary
import MHUI
import SwiftUI

struct DashboardSupportingFeature: View {
    @Environment(\.mhTheme)
    private var theme

    let highlight: DashboardSupportingHighlight

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            DashboardSupportingFeatureArtwork(
                systemImage: highlight.systemImage
            )

            highlightLabel
                .mhTextStyle(.metadata, colorRole: .tertiaryText)

            highlightTitle
                .mhTextStyle(.bodyStrong)

            highlightDetails
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .mhSurfaceInset()
    }

    @ViewBuilder private var highlightLabel: some View {
        switch highlight {
        case .archived:
            Text("Recently archived")
        case .milestone:
            Text("Milestone")
        case .activity(let activity):
            Text(activity.kind.label)
        }
    }

    @ViewBuilder private var highlightTitle: some View {
        switch highlight {
        case .archived(_, let title, _):
            Text(title)
        case .milestone(let milestone):
            Text(milestone.title)
        case .activity(let activity):
            Text(activity.title)
        }
    }

    @ViewBuilder private var highlightDetails: some View {
        switch highlight {
        case .archived(_, _, let date):
            Text(date, format: .dateTime.year().month().day())
                .mhTextStyle(.caption, colorRole: .secondaryText)
        case .milestone(let milestone):
            Text(verbatim: "\(milestone.durationText) – \(milestone.daysRemainingText)")
                .mhTextStyle(.supporting, colorRole: .secondaryText)

            Text(verbatim: milestone.date.precision.startLabel(for: milestone.date))
                .mhTextStyle(.caption, colorRole: .secondaryText)

            if milestone.isApproximate {
                Text("Approximate milestone")
                    .mhBadge(style: .neutral)
            }
        case .activity(let activity):
            Text(activity.date, format: .dateTime.year().month().day())
                .mhTextStyle(.caption, colorRole: .secondaryText)
        }
    }
}
