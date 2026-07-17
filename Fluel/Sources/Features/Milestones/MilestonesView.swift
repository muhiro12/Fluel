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
    @Query private var entries: [Entry]

    var body: some View {
        List {
            if !milestones.isEmpty {
                Section {
                    ForEach(milestones) { milestone in
                        MilestoneRowView(
                            milestone: milestone,
                            approximateLabel: Text("Approximate start")
                        )
                        .mhRow()
                    }
                } header: {
                    MHSectionHeader("Upcoming milestones")
                }
            }
        }
        .mhListChrome()
        .overlay {
            if milestones.isEmpty {
                MilestonesEmptyState()
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
