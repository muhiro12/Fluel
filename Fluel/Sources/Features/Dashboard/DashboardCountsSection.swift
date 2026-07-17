//
//  DashboardCountsSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct DashboardCountsSection: View {
    @Environment(\.mhTheme)
    private var theme

    let summary: EntryDashboardSummary

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.section) {
            MHSummary(
                title: Text(summary.totalCount, format: .number),
                metadata: Text("Total entries"),
                supporting: Text("Active and archived entries stay visible together.")
            ) {
                FluelBadgeStack {
                    Text("\(summary.activeCount) active")
                        .mhBadge(style: .accent)

                    Text("\(summary.archivedCount) archived")
                        .mhBadge(style: .neutral)
                }
            }

            MHGroupedRows {
                LabeledContent("With note", value: summary.noteCount.formatted())
                    .labeledContentStyle(.mhKeyValue)

                LabeledContent("With photo", value: summary.photoCount.formatted())
                    .labeledContentStyle(.mhKeyValue)
            }
            .mhSection(
                "Details",
                supporting: "Supporting context stays quieter than the entry total."
            )
        }
    }
}
