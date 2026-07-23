//
//  DashboardHighlightsLayout.swift
//  Fluel
//
//  Created by Codex on 2026/07/23.
//

import FluelLibrary
import MHUI
import SwiftUI

struct DashboardHighlightsLayout: View {
    private enum Layout {
        static let supportingFeatureCount = 2
    }

    @Environment(\.mhTheme)
    private var theme

    let activeEntry: EntrySnapshot?
    let archivedEntry: EntrySnapshot?
    let milestone: EntryMilestone?
    let activity: EntryActivitySummary?

    var body: some View {
        let resolvedSupportingHighlights = supportingHighlights

        if let activeEntry {
            if resolvedSupportingHighlights.count == Layout.supportingFeatureCount {
                MHFeatureGrid {
                    DashboardTimeTogetherFeature(
                        title: activeEntry.title,
                        timeTogether: EntryOperations.timeTogether(
                            for: activeEntry
                        ).primaryText
                    )
                } supporting: {
                    ForEach(resolvedSupportingHighlights) { highlight in
                        DashboardSupportingFeature(highlight: highlight)
                            .frame(maxHeight: .infinity, alignment: .topLeading)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.content) {
                    DashboardTimeTogetherFeature(
                        title: activeEntry.title,
                        timeTogether: EntryOperations.timeTogether(
                            for: activeEntry
                        ).primaryText
                    )

                    ForEach(resolvedSupportingHighlights) { highlight in
                        DashboardSupportingFeature(highlight: highlight)
                    }
                }
            }
        } else {
            VStack(alignment: .leading, spacing: theme.spacing.content) {
                ForEach(resolvedSupportingHighlights) { highlight in
                    DashboardSupportingFeature(highlight: highlight)
                }
            }
        }
    }

    private var supportingHighlights: [DashboardSupportingHighlight] {
        var highlights: [DashboardSupportingHighlight] = []

        if let archivedEntry,
           let archivedAt = archivedEntry.archivedAt {
            highlights.append(.archived(
                entryID: archivedEntry.id,
                title: archivedEntry.title,
                date: archivedAt
            ))
        }

        if let milestone {
            highlights.append(.milestone(milestone))
        }

        if highlights.count < Layout.supportingFeatureCount,
           let activity,
           !isDuplicateArchivedActivity(activity) {
            highlights.append(.activity(activity))
        }

        return Array(highlights.prefix(Layout.supportingFeatureCount))
    }

    private func isDuplicateArchivedActivity(
        _ activity: EntryActivitySummary
    ) -> Bool {
        activity.kind == .archived
            && activity.entryID == archivedEntry?.id
    }
}
