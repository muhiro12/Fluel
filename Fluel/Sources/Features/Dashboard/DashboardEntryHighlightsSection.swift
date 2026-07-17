//
//  DashboardEntryHighlightsSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct DashboardEntryHighlightsSection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let summary: EntryDashboardSummary

    var body: some View {
        Section {
            if let entry = summary.longestRunningActiveEntry {
                highlight(
                    label: "Longest together right now",
                    title: entry.title,
                    detail: EntryOperations.timeTogether(for: entry).primaryText,
                    showsTimeTogetherMark: true
                )
            }

            if let entry = summary.recentlyArchivedEntry,
               let archivedAt = entry.archivedAt {
                highlight(
                    label: "Recently archived",
                    title: entry.title,
                    detail: archivedAt.formatted(date: .abbreviated, time: .omitted),
                    showsTimeTogetherMark: false
                )
            }
        } header: {
            MHSectionHeader("Highlights")
        }
    }

    private func highlight(
        label: LocalizedStringKey,
        title: String,
        detail: String,
        showsTimeTogetherMark: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text(label)
                .mhTextStyle(.metadata, colorRole: .secondaryText)

            Text(title)
                .mhRowTitle()

            if showsTimeTogetherMark {
                FluelTimeTogetherLabel(text: detail)
            } else {
                Text(detail)
                    .mhRowSupporting()
            }
        }
        .mhRow()
    }
}
