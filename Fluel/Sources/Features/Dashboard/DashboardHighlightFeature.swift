//
//  DashboardHighlightFeature.swift
//  Fluel
//
//  Created by Codex on 2026/07/23.
//

import FluelLibrary
import Foundation
import MHUI
import SwiftUI

struct DashboardHighlightFeature: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let label: LocalizedStringKey
    let title: String
    let detail: String
    let showsTimeTogetherMark: Bool

    var body: some View {
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
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }

    static func longestTogether(_ entry: EntrySnapshot) -> Self {
        .init(
            label: "Longest together right now",
            title: entry.title,
            detail: EntryOperations.timeTogether(for: entry).primaryText,
            showsTimeTogetherMark: true
        )
    }

    static func recentlyArchived(
        _ entry: EntrySnapshot,
        at archivedAt: Date
    ) -> Self {
        .init(
            label: "Recently archived",
            title: entry.title,
            detail: archivedAt.formatted(date: .abbreviated, time: .omitted),
            showsTimeTogetherMark: false
        )
    }
}
