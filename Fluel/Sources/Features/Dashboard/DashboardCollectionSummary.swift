//
//  DashboardCollectionSummary.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct DashboardCollectionSummary: View {
    let totalCount: Int
    let activeCount: Int
    let archivedCount: Int

    var body: some View {
        MHSummary(
            title: Text(totalCount, format: .number),
            metadata: Text("Total entries"),
            supporting: Text("Active and archived entries stay visible together.")
        ) {
            FluelBadgeStack {
                Text("\(activeCount) active")
                    .mhBadge(style: .accent)

                Text("\(archivedCount) archived")
                    .mhBadge(style: .neutral)
            }
        }
    }
}
