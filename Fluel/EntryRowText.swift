//
//  EntryRowText.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import MHUI
import SwiftUI

struct EntryRowText: View {
    private enum Layout {
        static let verticalSpacing: CGFloat = 6
    }

    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.verticalSpacing) {
            Text(entry.title)
                .mhRowTitle()

            Text(entry.startPrecision.startLabel(for: entry.startDate))
                .mhRowSupporting()

            if entry.startPrecision.isApproximate {
                Text("Approximate start")
                    .mhBadge(
                        style: .neutral,
                        accessibilityLabel: Text("Approximate start")
                    )
            }
        }
    }
}
