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
    let approximateLabel: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text(milestone.title)
                .mhRowTitle()

            Text("\(milestone.durationText) - \(milestone.daysRemainingText)")
                .mhRowSupporting()

            Text(milestone.date.precision.startLabel(for: milestone.date))
                .mhRowSupporting()

            if milestone.isApproximate {
                Text(approximateLabel)
                    .mhBadge(
                        style: .neutral,
                        accessibilityLabel: Text(approximateLabel)
                    )
            }
        }
    }
}
