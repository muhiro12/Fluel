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
    @Query(sort: \Entry.startDate, order: .forward)
    private var entries: [Entry]

    var body: some View {
        List {
            if milestones.isEmpty {
                MilestonesEmptyState()
            } else {
                Section {
                    ForEach(milestones) { milestone in
                        MilestoneRowView(
                            milestone: milestone,
                            approximateLabel: "Approximate start"
                        )
                    }
                } header: {
                    FluelSectionHeader("Upcoming milestones")
                }
            }
        }
        .navigationTitle("Milestones")
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
