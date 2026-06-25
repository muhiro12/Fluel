//
//  EntryTimeTogetherSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import MHUI
import SwiftUI

struct EntryTimeTogetherSection: View {
    let entry: Entry

    var body: some View {
        let summary = entry.timeTogether()

        Section("Time together") {
            LabeledContent("Elapsed in full", value: summary.fullText)

            if let label = summary.totalValueLabel,
               let value = summary.totalValueText {
                LabeledContent(label, value: value)
            }
        }
        .labeledContentStyle(.mhKeyValue)
    }
}
