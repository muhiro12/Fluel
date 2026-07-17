//
//  MilestonesView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct MilestonesView: View {
    @Environment(\.mhTheme)
    private var theme

    @Query private var entries: [Entry]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.section) {
            if let nearestMilestone = milestones.first {
                MilestoneNextSummary(milestone: nearestMilestone)

                if milestones.count > 1 {
                    MHGroupedRows {
                        ForEach(milestones.dropFirst()) { milestone in
                            MilestoneRowView(
                                milestone: milestone,
                                approximateLabel: Text("Approximate start")
                            )
                        }
                    }
                    .mhSection(
                        "Upcoming milestones",
                        supporting: "The milestones that follow the nearest yearly moment."
                    )
                }
            } else {
                MilestonesEmptyState()
            }
        }
        .mhScreen(
            "Milestones",
            subtitle: "Yearly moments that are drawing closer."
        )
    }

    private var milestones: [EntryMilestone] {
        EntryOperations.upcomingMilestones(from: entries.map(\.snapshot))
    }
}

#Preview("Milestones - empty") {
    NavigationStack {
        MilestonesView()
    }
    .mhTheme(.standard)
    .modelContainer(PreviewSampleData.emptyContainer())
}

#Preview("Milestones - upcoming") {
    NavigationStack {
        MilestonesView()
    }
    .mhTheme(.standard)
    .modelContainer(PreviewSampleData.container())
}
