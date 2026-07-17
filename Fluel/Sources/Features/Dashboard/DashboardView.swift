//
//  DashboardView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.mhTheme)
    private var theme

    @Query(sort: \Entry.updatedAt, order: .reverse)
    private var entries: [Entry]

    @Query(sort: \EntryActivity.occurredAt, order: .reverse)
    private var activity: [EntryActivity]

    var body: some View {
        let summary = EntryOperations.dashboardSummary(
            from: entries.map(\.snapshot),
            activity: activity.map(\.summary)
        )

        VStack(alignment: .leading, spacing: theme.spacing.section) {
            DashboardCountsSection(summary: summary)

            DashboardEntryHighlightsSection(summary: summary)

            if !summary.upcomingMilestones.isEmpty {
                DashboardMilestonesSection(milestones: summary.upcomingMilestones)
            }

            if !summary.recentActivity.isEmpty {
                DashboardRecentActivitySection(activity: summary.recentActivity)
            }
        }
        .mhScreen(
            "Dashboard",
            subtitle: "A quiet view of the time held across your entries."
        )
    }
}

#Preview("Dashboard - empty") {
    NavigationStack {
        DashboardView()
    }
    .mhTheme(.standard)
    .modelContainer(PreviewSampleData.emptyContainer())
}

#Preview("Dashboard - typical") {
    NavigationStack {
        DashboardView()
    }
    .mhTheme(.standard)
    .modelContainer(PreviewSampleData.container())
}

#Preview("Dashboard - dense") {
    NavigationStack {
        DashboardView()
    }
    .mhTheme(.standard)
    .modelContainer(PreviewSampleData.denseContainer())
}
