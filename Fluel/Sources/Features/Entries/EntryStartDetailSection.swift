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
        Section {
            LabeledContent("Start", value: entry.start.precision.startLabel(for: entry.start))
            LabeledContent("Precision", value: entry.start.precision.knownAsText)

            if let rangeLabel = entry.start.precision.startRangeLabel(for: entry.start) {
                LabeledContent("Start range", value: rangeLabel)
            }
        } header: {
            FluelSectionHeader("Start")
        }
        .labeledContentStyle(.mhKeyValue)
    }
}
