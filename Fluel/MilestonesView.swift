//
//  MilestonesView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
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
                Section("Upcoming milestones") {
                    ForEach(milestones) { milestone in
                        MilestoneRowView(milestone: milestone)
                    }
                }
            }
        }
        .navigationTitle("Milestones")
    }

    private var milestones: [EntryMilestone] {
        EntryOperations.upcomingMilestones(from: entries.map(\.snapshot))
    }
}

#Preview {
    NavigationStack {
        MilestonesView()
    }
    .modelContainer(PreviewSampleData.container())
}
