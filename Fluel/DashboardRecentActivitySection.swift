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
    private enum Layout {
        static let verticalSpacing: CGFloat = 4
    }

    let activity: [EntryActivitySummary]

    var body: some View {
        Section("Recent activity") {
            ForEach(activity) { item in
                VStack(alignment: .leading, spacing: Layout.verticalSpacing) {
                    Text(item.kind.label)
                        .mhRowOverline()

                    Text(item.title)
                        .mhRowTitle()

                    Text(item.date.formatted(date: .abbreviated, time: .omitted))
                        .mhRowSupporting()
                }
            }
        }
    }
}
