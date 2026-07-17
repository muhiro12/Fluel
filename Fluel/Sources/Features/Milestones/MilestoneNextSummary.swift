//
//  MilestoneNextSummary.swift
//  Fluel
//
//  Created by Codex on 2026/07/18.
//

import FluelLibrary
import MHUI
import SwiftUI

struct MilestoneNextSummary: View {
    let milestone: EntryMilestone

    var body: some View {
        MHSummary(
            title: Text(verbatim: milestone.daysRemainingText),
            metadata: Text("Next milestone"),
            supporting: Text(verbatim: supportingText)
        ) {
            if milestone.isApproximate {
                Text("Approximate start")
                    .mhBadge(
                        style: .neutral,
                        accessibilityLabel: Text("Approximate milestone")
                    )
            }
        }
    }

    private var supportingText: String {
        let date = milestone.date.precision.startLabel(for: milestone.date)
        return "\(milestone.title) · \(milestone.durationText) · \(date)"
    }
}
