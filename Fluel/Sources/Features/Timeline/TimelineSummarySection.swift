//
//  TimelineSummarySection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct TimelineSummarySection: View {
    let summary: EntryTimelineSummary

    var body: some View {
        MHSummary(
            title: Text(summary.visibleActivityCount, format: .number),
            metadata: Text("Visible activity"),
            supporting: Text(verbatim: supportingText)
        ) {
            FluelBadgeStack {
                Text(verbatim: "\(summary.addedCount.formatted()) \(String(localized: "Added"))")
                    .mhBadge(style: .accent)

                Text(verbatim: "\(summary.updatedCount.formatted()) \(String(localized: "Updated"))")
                    .mhBadge(style: .neutral)

                Text(verbatim: "\(summary.archivedCount.formatted()) \(String(localized: "Archived"))")
                    .mhBadge(style: .neutral)
            }
        }
    }

    private var supportingText: String {
        let totalLabel = String(localized: "Total")
        let monthsLabel = String(localized: "Months")

        return "\(totalLabel): \(summary.totalActivityCount.formatted()) · "
            + "\(monthsLabel): \(summary.representedMonthCount.formatted())"
    }
}
