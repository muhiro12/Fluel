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
        let distinctRecentActivity = summary.recentActivity.first { activity in
            activity.kind != .archived
                || activity.entryID != summary.recentlyArchivedEntry?.id
        }

        VStack(alignment: .leading, spacing: theme.spacing.section) {
            DashboardCollectionSummary(
                totalCount: summary.totalCount,
                activeCount: summary.activeCount,
                archivedCount: summary.archivedCount
            )

            DashboardEntryHighlightsSection(
                activeEntry: summary.longestRunningActiveEntry,
                archivedEntry: summary.recentlyArchivedEntry,
                milestone: summary.upcomingMilestones.first,
                activity: distinctRecentActivity
            )

            DashboardDetailsSection(
                noteCount: summary.noteCount,
                photoCount: summary.photoCount
            )

            if summary.upcomingMilestones.count > 1 {
                DashboardMilestonesSection(
                    milestones: Array(summary.upcomingMilestones.dropFirst())
                )
            }

            if !summary.recentActivity.isEmpty {
                DashboardRecentActivitySection(activity: summary.recentActivity)
            }

            FluelTestAdView()
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
