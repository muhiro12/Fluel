//
//  EntryRowText.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftUI

struct EntryRowText: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text(entry.title)
                .mhRowTitle()

            Text(entry.startPrecision.startLabel(for: entry.startDate))
                .mhRowSupporting()

            FluelBadgeStack {
                if entry.startPrecision.isApproximate {
                    Text("Approximate start")
                        .mhBadge(
                            style: .neutral,
                            accessibilityLabel: Text("Approximate start")
                        )
                }

                if entry.hasNote {
                    Text("Note")
                        .mhBadge(
                            style: .neutral,
                            accessibilityLabel: Text("Has note")
                        )
                }

                if entry.hasPhoto {
                    Text("Photo")
                        .mhBadge(
                            style: .neutral,
                            accessibilityLabel: Text("Has photo")
                        )
                }
            }
        }
    }
}
