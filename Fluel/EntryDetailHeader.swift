//
//  EntryDetailHeader.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftUI

struct EntryDetailHeader: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let entry: Entry

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: designMetrics.spacing.control) {
                Text("Time together")
                    .mhRowOverline()

                Text(entry.timeTogether().primaryText)
                    .mhTextStyle(.screenTitle, colorRole: .accent)

                if let supportingText = entry.timeTogether().supportingText {
                    Text(supportingText)
                        .mhRowSupporting()
                }
            }
            .padding(.vertical, designMetrics.spacing.inline)
        }
    }
}
