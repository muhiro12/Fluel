//
//  DashboardMilestonesSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct DashboardMilestonesSection: View {
    private enum Layout {
        static let verticalSpacing: CGFloat = 4
    }

    let milestones: [EntryMilestone]

    var body: some View {
        Section("Upcoming milestones") {
            ForEach(milestones) { milestone in
                VStack(alignment: .leading, spacing: Layout.verticalSpacing) {
                    Text(milestone.title)
                        .mhRowTitle()

                    Text("\(milestone.durationText) - \(daysRemainingText(for: milestone))")
                        .mhRowSupporting()

                    Text(milestone.date.formatted(date: .abbreviated, time: .omitted))
                        .mhRowSupporting()

                    if milestone.isApproximate {
                        Text("Approximate milestone")
                            .mhBadge(
                                style: .neutral,
                                accessibilityLabel: Text("Approximate milestone")
                            )
                    }
                }
            }
        }
    }

    private func daysRemainingText(for milestone: EntryMilestone) -> String {
        switch milestone.daysRemaining {
        case 0:
            "Today"
        case 1:
            "1 day"
        default:
            "\(milestone.daysRemaining.formatted()) days"
        }
    }
}
