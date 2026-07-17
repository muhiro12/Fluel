//
//  MilestoneRowView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct MilestoneRowView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let milestone: EntryMilestone
    let approximateLabel: Text

    var body: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text(verbatim: milestone.title)
                .mhRowTitle()

            Text(verbatim: "\(milestone.durationText) – \(milestone.daysRemainingText)")
                .mhRowSupporting()

            Text(verbatim: milestone.date.precision.startLabel(for: milestone.date))
                .mhRowSupporting()

            if milestone.isApproximate {
                approximateLabel
                    .mhBadge(
                        style: .neutral,
                        accessibilityLabel: approximateLabel
                    )
            }
        }
    }
}
