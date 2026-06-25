//
//  DashboardView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query(sort: \Entry.updatedAt, order: .reverse)
    private var entries: [Entry]

    var body: some View {
        List {
            DashboardCountsSection(summary: summary)

            DashboardEntryHighlightsSection(summary: summary)

            if !summary.upcomingMilestones.isEmpty {
                DashboardMilestonesSection(milestones: summary.upcomingMilestones)
            }

            if !summary.recentActivity.isEmpty {
                DashboardRecentActivitySection(activity: summary.recentActivity)
            }
        }
        .navigationTitle("Dashboard")
    }

    private var summary: EntryDashboardSummary {
        EntryOperations.dashboardSummary(from: entries.map(\.snapshot))
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(PreviewSampleData.container())
}
