//
//  EntryStartDetailSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftUI

struct EntryStartDetailSection: View {
    let entry: Entry

    var body: some View {
        MHGroupedRows {
            LabeledContent("Start", value: entry.start.precision.startLabel(for: entry.start))
                .labeledContentStyle(.mhKeyValue)

            LabeledContent("Precision", value: entry.start.precision.knownAsText)
                .labeledContentStyle(.mhKeyValue)

            if let rangeLabel = entry.start.precision.startRangeLabel(for: entry.start) {
                LabeledContent("Start range", value: rangeLabel)
                    .labeledContentStyle(.mhKeyValue)
            }
        }
        .mhSection(
            "Start",
            supporting: "The date and precision Fluel uses to keep time."
        )
    }
}
