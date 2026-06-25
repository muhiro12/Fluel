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
    private enum Layout {
        static let verticalSpacing: CGFloat = 4
    }

    let summary: EntryDashboardSummary

    var body: some View {
        Section("Highlights") {
            if let entry = summary.longestRunningActiveEntry {
                highlight(
                    label: "Longest together right now",
                    title: entry.title,
                    detail: EntryOperations.timeTogether(for: entry).primaryText
                )
            }

            if let entry = summary.recentlyArchivedEntry,
               let archivedAt = entry.archivedAt {
                highlight(
                    label: "Recently archived",
                    title: entry.title,
                    detail: archivedAt.formatted(date: .abbreviated, time: .omitted)
                )
            }
        }
    }

    private func highlight(
        label: String,
        title: String,
        detail: String
    ) -> some View {
        VStack(alignment: .leading, spacing: Layout.verticalSpacing) {
            Text(label)
                .mhRowOverline()

            Text(title)
                .mhRowTitle()

            Text(detail)
                .mhRowSupporting()
        }
    }
}
