//
//  DashboardRecentActivitySection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct DashboardRecentActivitySection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let activity: [EntryActivitySummary]

    var body: some View {
        Section {
            ForEach(activity) { item in
                VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                    Text(item.kind.label)
                        .mhRowOverline()

                    Text(item.title)
                        .mhRowTitle()

                    Text(item.date.formatted(date: .abbreviated, time: .omitted))
                        .mhRowSupporting()
                }
                .mhRow()
            }
        } header: {
            MHSectionHeader("Recent activity")
        }
    }
}
